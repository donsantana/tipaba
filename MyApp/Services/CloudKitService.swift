//
//  CloudKitService.swift
//  Tipaba
//
//  Created by Done Santana on 10/25/26.
//

import CloudKit


enum CloudKitServiceError: LocalizedError {
    case iCloudAccountUnavailable
    case iCloudAccountRestricted
    case iCloudStatusUnavailable
    case invalidCredentials
    case invalidUserRecord
    case invalidPatientRecord

    var errorDescription: String? {
        switch self {
        case .iCloudAccountUnavailable:
            return "Sign in to iCloud and enable iCloud Drive before continuing."
        case .iCloudAccountRestricted:
            return "This iCloud account is restricted and cannot access account data."
        case .iCloudStatusUnavailable:
            return "The iCloud account is temporarily unavailable. Please try again later."
        case .invalidCredentials:
            return "The phone number or password is incorrect."
        case .invalidUserRecord:
            return "The encrypted user record is incomplete or invalid."
        case .invalidPatientRecord:
            return "The encrypted patient record is incomplete or invalid."
        }
    }
}

final class CloudKitService {
    static let shared = CloudKitService()

    private enum RecordType {
        static let user = "User"
        static let patient = "Patient"
    }

    private enum UserField {
        static let firstname = "firstname"
        static let lastname = "lastname"
        static let password = "password"
        static let phoneNumber = "phoneNumber"
        static let rol = "rol"
    }

    private enum PatientField {
        static let firstname = "firstname"
        static let lastname = "lastname"
    }

    let cloudContainer: CKContainer
    private let database: CKDatabase
    private let encryptionService: EncryptionService

    init(encryptionService: EncryptionService = .shared) {
        let container = CKContainer(identifier: GlobalConstants.cloudKitID)
        cloudContainer = container
        database = container.privateCloudDatabase
        self.encryptionService = encryptionService
    }

    @discardableResult
    func register(user: User) async throws -> CKRecord.ID {
        let accountStatus = try await cloudContainer.accountStatus()

        switch accountStatus {
        case .available:
            break
        case .noAccount:
            throw CloudKitServiceError.iCloudAccountUnavailable
        case .restricted:
            throw CloudKitServiceError.iCloudAccountRestricted
        case .couldNotDetermine, .temporarilyUnavailable:
            throw CloudKitServiceError.iCloudStatusUnavailable
        @unknown default:
            throw CloudKitServiceError.iCloudStatusUnavailable
        }

        let record = CKRecord(recordType: RecordType.user)
        record[UserField.firstname] = try encryptedString(user.firstname) as CKRecordValue
        record[UserField.lastname] = try encryptedString(user.lastname) as CKRecordValue
        record[UserField.password] = try encryptedString(user.password) as CKRecordValue
        record[UserField.phoneNumber] = try encryptedString(user.phoneNumber) as CKRecordValue
        record[UserField.rol] = try encryptedString(user.rol) as CKRecordValue

        let savedRecord = try await database.save(record)
        return savedRecord.recordID
    }

    func signIn(phoneNumber: String, password: String) async throws -> User {
        let users = try await fetchUsers()
        guard let user = users.first(where: {
            $0.phoneNumber == phoneNumber && $0.password == password
        }) else {
            throw CloudKitServiceError.invalidCredentials
        }
        return user
    }

    func fetchUsers() async throws -> [User] {
        let query = CKQuery(recordType: RecordType.user, predicate: NSPredicate(value: true))
        var response = try await database.records(matching: query)
        var users = try decodeUsers(from: response.matchResults)

        while let cursor = response.queryCursor {
            response = try await database.records(continuingMatchFrom: cursor)
            users.append(contentsOf: try decodeUsers(from: response.matchResults))
        }

        return users
    }

    func fetchPatients() async throws -> [Patient] {
        let query = CKQuery(recordType: RecordType.patient, predicate: NSPredicate(value: true))
        var response = try await database.records(matching: query)
        var patients = try decodePatients(from: response.matchResults)

        while let cursor = response.queryCursor {
            response = try await database.records(continuingMatchFrom: cursor)
            patients.append(contentsOf: try decodePatients(from: response.matchResults))
        }

        return patients
    }

    private func decodePatients(
        from results: [(CKRecord.ID, Result<CKRecord, any Error>)]
    ) throws -> [Patient] {
        try results.map { _, result in
            let record = try result.get()
            guard let firstname = record[PatientField.firstname] as? String,
                  let lastname = record[PatientField.lastname] as? String else {
                throw CloudKitServiceError.invalidPatientRecord
            }
            return try Patient(
                id: record.recordID.recordName,
                firstname: decryptedString(firstname),
                lastname: decryptedString(lastname)
            )
        }
    }

    private func decodeUsers(
        from results: [(CKRecord.ID, Result<CKRecord, any Error>)]
    ) throws -> [User] {
        try results.map { _, result in
            try user(from: result.get())
        }
    }

    private func user(from record: CKRecord) throws -> User {
        guard
            let encryptedFirstname = record[UserField.firstname] as? String,
            let encryptedLastname = record[UserField.lastname] as? String,
            let encryptedPassword = record[UserField.password] as? String,
            let encryptedPhoneNumber = record[UserField.phoneNumber] as? String,
            let encryptedRol = record[UserField.rol] as? String
        else {
            throw CloudKitServiceError.invalidUserRecord
        }

        return try User(
            firstname: decryptedString(encryptedFirstname),
            lastname: decryptedString(encryptedLastname),
            password: decryptedString(encryptedPassword),
            phoneNumber: decryptedString(encryptedPhoneNumber),
            rol: decryptedString(encryptedRol)
        )
    }

    private func encryptedString(_ value: String) throws -> String {
        try encryptionService.encrypt(value).base64EncodedString()
    }

    private func decryptedString(_ value: String) throws -> String {
        guard let encryptedData = Data(base64Encoded: value) else {
            throw CloudKitServiceError.invalidUserRecord
        }

        return try encryptionService.decrypt(encryptedData)
    }
}
