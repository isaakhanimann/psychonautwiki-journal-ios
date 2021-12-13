import Foundation
import CoreData
import SwiftyJSON

func decodeSubstancesFile(
    from data: Data,
    with context: NSManagedObjectContext
) throws -> SubstancesFile {

    let decoder = JSONDecoder()
    decoder.userInfo[CodingUserInfoKey.managedObjectContext] = context
    decoder.dateDecodingStrategy = .deferredToDate
    decoder.keyDecodingStrategy = .useDefaultKeys

    let json = try JSON(data: data)
    let dataForFile = try json["data"].rawData()

    return try decoder.decode(SubstancesFile.self, from: dataForFile)
}
