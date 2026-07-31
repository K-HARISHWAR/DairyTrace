"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const index_js_1 = require("@modelcontextprotocol/sdk/server/index.js");
const stdio_js_1 = require("@modelcontextprotocol/sdk/server/stdio.js");
const types_js_1 = require("@modelcontextprotocol/sdk/types.js");
const supabase_js_1 = require("@supabase/supabase-js");
const dotenv = __importStar(require("dotenv"));
// Load environment variables
dotenv.config();
// Ensure required environment variables are set
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
if (!supabaseUrl || !supabaseKey) {
    console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in environment");
    process.exit(1);
}
// Initialize Supabase admin client
const supabase = (0, supabase_js_1.createClient)(supabaseUrl, supabaseKey);
// Define MCP Tools
const getDashboardStatsTool = {
    name: "get_dashboard_stats",
    description: "Retrieves high-level KPIs for the DairyTrace supply chain (active batches, collected volume, rejected batches, critical alerts).",
    inputSchema: {
        type: "object",
        properties: {},
    },
};
const listRecentBatchesTool = {
    name: "list_recent_batches",
    description: "Returns a list of recently collected milk batches, their quantities, and their current status.",
    inputSchema: {
        type: "object",
        properties: {
            limit: {
                type: "number",
                description: "Number of batches to return (default: 10)",
            },
        },
    },
};
const getBatchJourneyTool = {
    name: "get_batch_journey",
    description: "Given a batch_code, retrieves its full lifecycle, including tracking events and quality checks.",
    inputSchema: {
        type: "object",
        properties: {
            batch_code: {
                type: "string",
                description: "The unique code of the batch (e.g. BCH-20260722-0001-a7b3)",
            },
        },
        required: ["batch_code"],
    },
};
const getActiveAlertsTool = {
    name: "get_active_alerts",
    description: "Retrieves all unresolved system alerts (e.g., temperature warnings, quality failures).",
    inputSchema: {
        type: "object",
        properties: {
            severity: {
                type: "string",
                description: "Filter by severity (info, low, medium, high, critical). Optional.",
                enum: ["info", "low", "medium", "high", "critical"],
            },
        },
    },
};
// Initialize MCP Server
const server = new index_js_1.Server({
    name: "dairytrace-mcp-server",
    version: "1.0.0",
}, {
    capabilities: {
        tools: {},
    },
});
// Register Tool Handlers
server.setRequestHandler(types_js_1.ListToolsRequestSchema, async () => {
    return {
        tools: [
            getDashboardStatsTool,
            listRecentBatchesTool,
            getBatchJourneyTool,
            getActiveAlertsTool,
        ],
    };
});
server.setRequestHandler(types_js_1.CallToolRequestSchema, async (request) => {
    try {
        switch (request.params.name) {
            case "get_dashboard_stats": {
                // Call the RPC function we built for the dashboard
                const { data, error } = await supabase.rpc("get_admin_dashboard_stats");
                if (error)
                    throw error;
                return {
                    content: [
                        {
                            type: "text",
                            text: JSON.stringify(data, null, 2),
                        },
                    ],
                };
            }
            case "list_recent_batches": {
                const args = request.params.arguments;
                const limit = args.limit || 10;
                const { data, error } = await supabase
                    .from("batches")
                    .select("*, farms(farm_name, farm_code)")
                    .order("collection_time", { ascending: false })
                    .limit(limit);
                if (error)
                    throw error;
                return {
                    content: [
                        {
                            type: "text",
                            text: JSON.stringify(data, null, 2),
                        },
                    ],
                };
            }
            case "get_batch_journey": {
                const args = request.params.arguments;
                const batchCode = args.batch_code;
                // Find batch
                const { data: batch, error: batchError } = await supabase
                    .from("batches")
                    .select("*, farms(*), collection_centres(*)")
                    .eq("batch_code", batchCode)
                    .single();
                if (batchError || !batch) {
                    return {
                        content: [{ type: "text", text: `Error finding batch: ${batchError?.message || 'Not found'}` }],
                        isError: true,
                    };
                }
                // Fetch tracking events
                const { data: events } = await supabase
                    .from("tracking_events")
                    .select("*")
                    .eq("batch_id", batch.id)
                    .order("event_time", { ascending: true });
                // Fetch quality checks
                const { data: quality } = await supabase
                    .from("quality_checks")
                    .select("*")
                    .eq("batch_id", batch.id)
                    .order("checked_at", { ascending: true });
                const journeyData = {
                    batchDetails: batch,
                    trackingHistory: events || [],
                    qualityChecks: quality || [],
                };
                return {
                    content: [
                        {
                            type: "text",
                            text: JSON.stringify(journeyData, null, 2),
                        },
                    ],
                };
            }
            case "get_active_alerts": {
                const args = request.params.arguments;
                const severity = args.severity;
                let query = supabase
                    .from("alerts")
                    .select("*, batches(batch_code)")
                    .eq("is_resolved", false)
                    .order("created_at", { ascending: false });
                if (severity) {
                    query = query.eq("severity", severity);
                }
                const { data, error } = await query;
                if (error)
                    throw error;
                return {
                    content: [
                        {
                            type: "text",
                            text: JSON.stringify(data, null, 2),
                        },
                    ],
                };
            }
            default:
                throw new Error(`Unknown tool: ${request.params.name}`);
        }
    }
    catch (error) {
        return {
            content: [
                {
                    type: "text",
                    text: `Error executing tool: ${error.message}`,
                },
            ],
            isError: true,
        };
    }
});
// Start Server
async function main() {
    const transport = new stdio_js_1.StdioServerTransport();
    await server.connect(transport);
    console.error("DairyTrace MCP Server running on stdio");
}
main().catch((error) => {
    console.error("Fatal error running MCP Server:", error);
    process.exit(1);
});
