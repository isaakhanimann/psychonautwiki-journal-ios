import Foundation

struct IngestionWithTimelineContext {
    let ingestion: Ingestion
    let insetIndex: Int
    let verticalWeight: Double
    let graphStartTime: Date
    let graphEndTime: Date
}
