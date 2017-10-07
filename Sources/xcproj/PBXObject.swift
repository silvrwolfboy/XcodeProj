import Foundation

/// Class that represents a project element.
public class PBXObject: Referenceable, Decodable {

    public var hashValue: Int { return self.reference.hashValue }

    /// Element unique reference.
    public var reference: String = ""

    init(reference: String) {
        self.reference = reference
    }

    // MARK: - Decodable
    
    fileprivate enum CodingKeys: String, CodingKey {
        case reference
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.reference = try container.decode(.reference)
    }
    
    public static var isa: String {
        return String(describing: self)
    }

    public static func parse(reference: String, dictionary: [String: Any]) throws -> PBXObject {
        let decoder = JSONDecoder()
        var mutableDictionary = dictionary
        mutableDictionary["reference"] = reference
        let data = try JSONSerialization.data(withJSONObject: mutableDictionary, options: [])
        guard let isa = dictionary["isa"] as? String else { throw PBXObjectError.missingIsa }
        switch isa {
        case PBXNativeTarget.isa:
            return try decoder.decode(PBXNativeTarget.self, from: data)
        case PBXAggregateTarget.isa:
            return try decoder.decode(PBXAggregateTarget.self, from: data)
        case PBXBuildFile.isa:
            return try decoder.decode(PBXBuildFile.self, from: data)
        case PBXFileReference.isa:
            return try decoder.decode(PBXFileReference.self, from: data)
        case PBXProject.isa:
            return try decoder.decode(PBXProject.self, from: data)
        case PBXFileElement.isa:
            return try decoder.decode(PBXFileElement.self, from: data)
        case PBXGroup.isa:
            return try decoder.decode(PBXGroup.self, from: data)
        case PBXHeadersBuildPhase.isa:
            return try decoder.decode(PBXHeadersBuildPhase.self, from: data)
        case PBXFrameworksBuildPhase.isa:
            return try decoder.decode(PBXFrameworksBuildPhase.self, from: data)
        case XCConfigurationList.isa:
            return try decoder.decode(XCConfigurationList.self, from: data)
        case PBXResourcesBuildPhase.isa:
            return try decoder.decode(PBXResourcesBuildPhase.self, from: data)
        case PBXShellScriptBuildPhase.isa:
            return try decoder.decode(PBXShellScriptBuildPhase.self, from: data)
        case PBXSourcesBuildPhase.isa:
            return try decoder.decode(PBXSourcesBuildPhase.self, from: data)
        case PBXTargetDependency.isa:
            return try decoder.decode(PBXTargetDependency.self, from: data)
        case PBXVariantGroup.isa:
            return try decoder.decode(PBXVariantGroup.self, from: data)
        case XCBuildConfiguration.isa:
            return try decoder.decode(XCBuildConfiguration.self, from: data)
        case PBXCopyFilesBuildPhase.isa:
            return try decoder.decode(PBXCopyFilesBuildPhase.self, from: data)
        case PBXContainerItemProxy.isa:
            return try decoder.decode(PBXContainerItemProxy.self, from: data)
        case PBXReferenceProxy.isa:
            return try decoder.decode(PBXReferenceProxy.self, from: data)
        case XCVersionGroup.isa:
            return try decoder.decode(XCVersionGroup.self, from: data)
        default:
            throw PBXObjectError.unknownElement(isa)
        }
    }
}

/// PBXObjectError
///
/// - missingIsa: the isa attribute is missing.
/// - unknownElement: the object type is not supported.
public enum PBXObjectError: Error, CustomStringConvertible {
    case missingIsa
    case unknownElement(String)

    public var description: String {
        switch self {
        case .missingIsa:
            return "Isa property is missing"
        case .unknownElement(let element):
            return "The element \(element) is not supported"
        }
    }
}

extension Array where Element: Referenceable {

    public var references: [String] {
        return map { $0.reference }
    }

    public func contains(reference: String) -> Bool {
        return contains { $0.reference == reference }
    }

    public func getReference(_ reference: String) -> Element? {
        return first { $0.reference == reference }
    }
}

public protocol Referenceable {
    var reference: String { get }
}