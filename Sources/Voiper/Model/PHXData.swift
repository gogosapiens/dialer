import Foundation

struct PHXData: Decodable, Encodable {
    let event: String
    let topic: String
    let payload: Payload
    let ref: String?
    
    struct Payload: Decodable, Encodable {
        let callSid: String?
        let parentCallSid: String?
        let status: String?
        
        enum CodingKeys: String, CodingKey {
            case callSid = "CallSid"
            case parentCallSid = "ParentCallSid"
            case status
        }
        
        init(callSid: String? = nil, parentCallSid: String? = nil, status: String? = nil) {
            self.callSid = callSid
            self.parentCallSid = parentCallSid
            self.status = status
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.callSid = try container.decodeIfPresent(String.self, forKey: .callSid)
            self.status = try container.decodeIfPresent(String.self, forKey: .status)
            self.parentCallSid = try container.decodeIfPresent(String.self, forKey: .parentCallSid)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(callSid, forKey: .callSid)
            try container.encodeIfPresent(status, forKey: .status)
            try container.encodeIfPresent(parentCallSid, forKey: .parentCallSid)
        }
    }
    
    enum CodingKeys: CodingKey {
        case event
        case topic
        case payload
        case ref
    }
    
    init(event: String, topic: String, payload: Payload) {
        self.event = event
        self.topic = topic
        self.payload = payload
        self.ref = nil
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.event = try container.decode(String.self, forKey: .event)
        self.topic = try container.decode(String.self, forKey: .topic)
        self.payload = try container.decode(PHXData.Payload.self, forKey: .payload)
        self.ref = try container.decodeIfPresent(String.self, forKey: .ref)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(event, forKey: .event)
        try container.encode(topic, forKey: .topic)
        try container.encode(payload, forKey: .payload)
        try container.encode(ref, forKey: .ref)
    }
}
