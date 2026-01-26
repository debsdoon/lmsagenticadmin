# Agent Development Guide

## Table of Contents

1. [Introduction](#introduction)
2. [Agent Architecture](#agent-architecture)
3. [Creating Your First Agent](#creating-your-first-agent)
4. [Agent Components](#agent-components)
5. [Tools and Actions](#tools-and-actions)
6. [Intent Processing](#intent-processing)
7. [Task Planning and Execution](#task-planning-and-execution)
8. [Error Handling](#error-handling)
9. [Testing Agents](#testing-agents)
10. [Best Practices](#best-practices)
11. [Advanced Patterns](#advanced-patterns)
12. [Troubleshooting](#troubleshooting)

## Introduction

Agents are specialized AI-powered components that handle specific domains within the LMS admin system. Each agent is responsible for understanding user intents, planning tasks, and executing actions within its domain of expertise.

### What is an Agent?

An agent in this system is:
- **Domain-Specific**: Focused on a particular area (users, courses, content, etc.)
- **Intelligent**: Uses LLM to understand natural language and plan tasks
- **Tool-Enabled**: Has access to specific tools/actions to interact with the system
- **Autonomous**: Can execute multi-step workflows independently
- **Safe**: Validates actions and requires approval for critical operations

### Agent Types

The system includes the following agent types:

- **User Agent**: User management, roles, permissions, bulk operations
- **Course Agent**: Course creation, enrollment, lifecycle management
- **Content Agent**: File management, content validation, organization
- **Analytics Agent**: Data analysis, insights, trend identification
- **System Agent**: Health monitoring, performance, maintenance
- **Support Agent**: Ticket management, automated responses
- **Security Agent**: Access control, audit logging, compliance
- **Reporting Agent**: Report generation, data export, visualization

## Agent Architecture

### High-Level Flow

```
User Input (Natural Language)
    │
    ▼
Intent Recognition (Orchestrator)
    │
    ▼
Agent Selection (Based on Intent)
    │
    ▼
Agent.processIntent()
    │
    ├─→ Simple Query → Direct Response
    │
    └─→ Complex Task → Task Planning
            │
            ├─→ Plan Creation (LLM)
            ├─→ Tool Execution
            ├─→ Result Validation
            └─→ Response Generation
```

### Agent Class Structure

```typescript
abstract class BaseAgent {
  // Core properties
  protected agentType: string;
  protected permissions: Permission[];
  protected llm: LLMClient;
  protected tools: Map<string, Tool>;
  protected logger: Logger;
  
  // Abstract methods (must be implemented)
  abstract async processIntent(
    intent: Intent, 
    context: Context
  ): Promise<AgentResponse>;
  
  // Protected helper methods (available to subclasses)
  protected async planTask(...): Promise<TaskPlan>;
  protected async executePlan(...): Promise<ExecutionResult>;
  protected async validateResult(...): Promise<ValidationResult>;
  protected async logAction(...): Promise<void>;
}
```

## Creating Your First Agent

### Step 1: Set Up the Agent File

Create a new file in the `agents/` directory:

```typescript
// agents/example-agent.ts
import { BaseAgent, Intent, Context, AgentResponse } from '../core/agent';
import { ExampleService } from '../services/example-service';

export class ExampleAgent extends BaseAgent {
  private exampleService: ExampleService;
  
  constructor(config: AgentConfig) {
    super(config);
    this.agentType = 'example';
    this.exampleService = new ExampleService();
    this.loadTools();
  }
  
  async processIntent(intent: Intent, context: Context): Promise<AgentResponse> {
    // Implementation here
  }
}
```

### Step 2: Register the Agent

Register your agent in the agent registry:

```typescript
// agents/registry.ts
import { ExampleAgent } from './example-agent';

export const agentRegistry = {
  // ... existing agents
  example: (config) => new ExampleAgent(config),
};
```

### Step 3: Define Supported Intents

Define what intents your agent can handle:

```typescript
export class ExampleAgent extends BaseAgent {
  private supportedIntents = [
    'create_example',
    'list_examples',
    'update_example',
    'delete_example'
  ];
  
  async processIntent(intent: Intent, context: Context): Promise<AgentResponse> {
    if (!this.supportedIntents.includes(intent.action)) {
      throw new Error(`Unsupported intent: ${intent.action}`);
    }
    
    switch (intent.action) {
      case 'create_example':
        return await this.createExample(intent, context);
      case 'list_examples':
        return await this.listExamples(intent, context);
      // ... other cases
    }
  }
}
```

### Step 4: Implement Intent Handlers

Implement handlers for each intent:

```typescript
private async createExample(intent: Intent, context: Context): Promise<AgentResponse> {
  // Extract parameters from intent
  const { name, description } = intent.parameters;
  
  // Validate input
  if (!name) {
    return {
      success: false,
      message: 'Name is required to create an example',
      requiresConfirmation: false
    };
  }
  
  // Plan the task
  const plan = await this.planTask(intent, context);
  
  // Execute the plan
  const result = await this.executePlan(plan);
  
  // Validate results
  const validation = await this.validateResult(result);
  
  return {
    success: validation.isValid,
    message: `Example "${name}" created successfully`,
    data: result.data,
    requiresConfirmation: false
  };
}
```

## Agent Components

### 1. Intent Processing

Intents represent user requests parsed from natural language:

```typescript
interface Intent {
  action: string;              // e.g., 'create_user', 'list_courses'
  parameters: Record<string, any>;  // Extracted parameters
  confidence: number;          // 0-1 confidence score
  entities: Entity[];          // Named entities (dates, names, etc.)
  originalText: string;        // Original user input
}
```

### 2. Context

Context provides additional information for the agent:

```typescript
interface Context {
  userId: string;              // Admin making the request
  sessionId: string;           // Current session
  conversationHistory: Message[];  // Previous messages
  currentPage?: string;        // Current UI page
  permissions: Permission[];   // User permissions
  metadata: Record<string, any>;   // Additional context
}
```

### 3. Agent Response

Responses communicate results back to the user:

```typescript
interface AgentResponse {
  success: boolean;
  message: string;             // Human-readable message
  data?: any;                  // Response data
  requiresConfirmation: boolean;  // Needs admin approval?
  confirmationDetails?: ConfirmationDetails;
  suggestions?: Suggestion[];  // Proactive suggestions
  nextSteps?: string[];        // Suggested follow-up actions
}
```

### 4. Task Planning

For complex tasks, agents create execution plans:

```typescript
interface TaskPlan {
  steps: TaskStep[];
  estimatedDuration: number;
  requiredPermissions: Permission[];
  riskLevel: 'low' | 'medium' | 'high';
  rollbackPlan?: RollbackPlan;
}

interface TaskStep {
  id: string;
  action: string;
  tool: string;
  parameters: Record<string, any>;
  dependencies: string[];      // Step IDs this depends on
  retryable: boolean;
}
```

## Tools and Actions

Tools are the interface between agents and the system. Each agent has access to specific tools.

### Creating a Tool

```typescript
// tools/user-tools.ts
import { Tool } from '../core/tool';

export class CreateUserTool extends Tool {
  name = 'create_user';
  description = 'Creates a new user account in the system';
  
  parameters = {
    email: {
      type: 'string',
      required: true,
      description: 'User email address'
    },
    name: {
      type: 'string',
      required: true,
      description: 'User full name'
    },
    role: {
      type: 'string',
      required: true,
      enum: ['student', 'instructor', 'admin'],
      description: 'User role'
    }
  };
  
  async execute(params: any, context: Context): Promise<ToolResult> {
    // Validate permissions
    if (!context.permissions.includes('user:create')) {
      throw new Error('Insufficient permissions');
    }
    
    // Execute the action
    const user = await this.userService.createUser(params);
    
    // Log the action
    await this.auditLog.log({
      action: 'user:create',
      userId: context.userId,
      entityId: user.id,
      changes: params
    });
    
    return {
      success: true,
      data: user,
      message: `User ${user.email} created successfully`
    };
  }
}
```

### Registering Tools

```typescript
export class UserAgent extends BaseAgent {
  protected loadTools(): void {
    this.tools.set('create_user', new CreateUserTool());
    this.tools.set('update_user', new UpdateUserTool());
    this.tools.set('delete_user', new DeleteUserTool());
    this.tools.set('list_users', new ListUsersTool());
    // ... more tools
  }
}
```

### Using Tools in Agents

```typescript
private async createUsers(intent: Intent, context: Context): Promise<AgentResponse> {
  const tool = this.tools.get('create_user');
  
  if (!tool) {
    throw new Error('create_user tool not available');
  }
  
  const result = await tool.execute(intent.parameters, context);
  
  return {
    success: result.success,
    message: result.message,
    data: result.data
  };
}
```

## Intent Processing

### Simple Query Processing

For simple queries that don't require multi-step execution:

```typescript
private async listExamples(intent: Intent, context: Context): Promise<AgentResponse> {
  // Extract filters from intent
  const filters = this.extractFilters(intent);
  
  // Direct execution
  const examples = await this.exampleService.list(filters);
  
  return {
    success: true,
    message: `Found ${examples.length} examples`,
    data: examples
  };
}
```

### Complex Task Processing

For complex tasks requiring planning:

```typescript
private async createCourseWithEnrollment(
  intent: Intent, 
  context: Context
): Promise<AgentResponse> {
  // Step 1: Plan the task
  const plan = await this.planTask(intent, context);
  
  // Step 2: Check if confirmation is needed
  if (plan.riskLevel === 'high' || plan.riskLevel === 'medium') {
    return {
      success: false,
      requiresConfirmation: true,
      confirmationDetails: {
        plan: plan,
        summary: this.generatePlanSummary(plan),
        estimatedImpact: this.assessImpact(plan)
      }
    };
  }
  
  // Step 3: Execute the plan
  const result = await this.executePlan(plan, context);
  
  // Step 4: Validate results
  const validation = await this.validateResult(result, plan);
  
  if (!validation.isValid) {
    // Rollback if needed
    if (plan.rollbackPlan) {
      await this.executeRollback(plan.rollbackPlan);
    }
    
    return {
      success: false,
      message: validation.errorMessage,
      data: result
    };
  }
  
  return {
    success: true,
    message: 'Course created and students enrolled successfully',
    data: result.data
  };
}
```

## Task Planning and Execution

### Creating a Task Plan

Agents use LLM to create execution plans:

```typescript
protected async planTask(intent: Intent, context: Context): Promise<TaskPlan> {
  const prompt = this.buildPlanningPrompt(intent, context);
  
  const llmResponse = await this.llm.generate(prompt, {
    temperature: 0.3,  // Lower temperature for more deterministic plans
    maxTokens: 2000
  });
  
  const plan = this.parsePlanFromLLM(llmResponse);
  
  // Validate plan structure
  this.validatePlan(plan);
  
  return plan;
}

private buildPlanningPrompt(intent: Intent, context: Context): string {
  return `
You are a ${this.agentType} agent planning a task.

User Intent: ${intent.originalText}
Action: ${intent.action}
Parameters: ${JSON.stringify(intent.parameters)}

Available Tools:
${Array.from(this.tools.values()).map(t => `- ${t.name}: ${t.description}`).join('\n')}

Context:
- User: ${context.userId}
- Permissions: ${context.permissions.join(', ')}
- Previous actions: ${context.conversationHistory.length} messages

Create a step-by-step execution plan. Each step should:
1. Use one of the available tools
2. Specify required parameters
3. List dependencies on other steps
4. Indicate if it's retryable

Return the plan as JSON matching this structure:
{
  "steps": [
    {
      "id": "step1",
      "action": "create_course",
      "tool": "create_course",
      "parameters": {...},
      "dependencies": [],
      "retryable": true
    }
  ],
  "estimatedDuration": 120,
  "riskLevel": "medium"
}
`;
}
```

### Executing a Plan

```typescript
protected async executePlan(
  plan: TaskPlan, 
  context: Context
): Promise<ExecutionResult> {
  const results: StepResult[] = [];
  const executionOrder = this.topologicalSort(plan.steps);
  
  for (const stepId of executionOrder) {
    const step = plan.steps.find(s => s.id === stepId);
    if (!step) continue;
    
    // Wait for dependencies
    await this.waitForDependencies(step, results);
    
    // Execute step
    try {
      const tool = this.tools.get(step.tool);
      if (!tool) {
        throw new Error(`Tool ${step.tool} not found`);
      }
      
      const stepResult = await tool.execute(step.parameters, context);
      results.push({
        stepId: step.id,
        success: stepResult.success,
        data: stepResult.data,
        error: stepResult.error
      });
      
      // Update context with step results for subsequent steps
      context = this.updateContextWithResult(context, stepResult);
      
    } catch (error) {
      results.push({
        stepId: step.id,
        success: false,
        error: error.message
      });
      
      // Handle retryable errors
      if (step.retryable) {
        const retryResult = await this.retryStep(step, context);
        if (retryResult.success) {
          results[results.length - 1] = retryResult;
          continue;
        }
      }
      
      // If step fails and is critical, abort
      if (this.isCriticalStep(step)) {
        return {
          success: false,
          steps: results,
          error: `Critical step ${step.id} failed: ${error.message}`
        };
      }
    }
  }
  
  return {
    success: true,
    steps: results,
    data: this.aggregateResults(results)
  };
}
```

## Error Handling

### Error Types

```typescript
enum AgentErrorType {
  VALIDATION_ERROR = 'validation_error',
  PERMISSION_ERROR = 'permission_error',
  EXECUTION_ERROR = 'execution_error',
  LLM_ERROR = 'llm_error',
  TIMEOUT_ERROR = 'timeout_error'
}
```

### Error Handling Strategy

```typescript
private async handleError(
  error: Error, 
  intent: Intent, 
  context: Context
): Promise<AgentResponse> {
  // Log error
  this.logger.error('Agent error', {
    agent: this.agentType,
    intent: intent.action,
    error: error.message,
    stack: error.stack
  });
  
  // Classify error
  const errorType = this.classifyError(error);
  
  switch (errorType) {
    case AgentErrorType.VALIDATION_ERROR:
      return {
        success: false,
        message: `Validation failed: ${error.message}`,
        requiresConfirmation: false,
        suggestions: this.getValidationSuggestions(error)
      };
      
    case AgentErrorType.PERMISSION_ERROR:
      return {
        success: false,
        message: 'You do not have permission to perform this action',
        requiresConfirmation: false
      };
      
    case AgentErrorType.EXECUTION_ERROR:
      // Attempt recovery
      const recovery = await this.attemptRecovery(error, intent, context);
      if (recovery.success) {
        return recovery.response;
      }
      
      return {
        success: false,
        message: `Action failed: ${error.message}`,
        requiresConfirmation: false,
        suggestions: ['Try again', 'Contact support']
      };
      
    default:
      return {
        success: false,
        message: 'An unexpected error occurred',
        requiresConfirmation: false
      };
  }
}
```

## Testing Agents

### Unit Testing

```typescript
// tests/agents/user-agent.test.ts
import { UserAgent } from '../agents/user-agent';
import { MockLLMClient, MockUserService } from './mocks';

describe('UserAgent', () => {
  let agent: UserAgent;
  let mockLLM: MockLLMClient;
  let mockService: MockUserService;
  
  beforeEach(() => {
    mockLLM = new MockLLMClient();
    mockService = new MockUserService();
    agent = new UserAgent({
      type: 'user',
      permissions: ['user:create', 'user:read'],
      llmConfig: { client: mockLLM }
    });
  });
  
  it('should create a user successfully', async () => {
    const intent = {
      action: 'create_user',
      parameters: {
        email: 'test@example.com',
        name: 'Test User',
        role: 'student'
      },
      confidence: 0.9,
      entities: [],
      originalText: 'Create a user test@example.com'
    };
    
    const context = {
      userId: 'admin1',
      sessionId: 'session1',
      conversationHistory: [],
      permissions: ['user:create']
    };
    
    const response = await agent.processIntent(intent, context);
    
    expect(response.success).toBe(true);
    expect(response.message).toContain('created successfully');
    expect(mockService.createUser).toHaveBeenCalledWith({
      email: 'test@example.com',
      name: 'Test User',
      role: 'student'
    });
  });
  
  it('should handle permission errors', async () => {
    const context = {
      userId: 'user1',
      sessionId: 'session1',
      conversationHistory: [],
      permissions: []  // No permissions
    };
    
    const intent = {
      action: 'create_user',
      parameters: { email: 'test@example.com', name: 'Test', role: 'student' },
      confidence: 0.9,
      entities: [],
      originalText: 'Create user'
    };
    
    const response = await agent.processIntent(intent, context);
    
    expect(response.success).toBe(false);
    expect(response.message).toContain('permission');
  });
});
```

### Integration Testing

```typescript
// tests/integration/agent-integration.test.ts
describe('Agent Integration', () => {
  it('should handle multi-agent coordination', async () => {
    // Test scenario where multiple agents work together
    const orchestrator = new AgentOrchestrator();
    
    const intent = {
      action: 'setup_semester',
      parameters: {
        courses: ['CS101', 'CS102'],
        semester: 'Fall 2026'
      },
      originalText: 'Set up fall semester with CS101 and CS102'
    };
    
    const result = await orchestrator.process(intent, context);
    
    // Verify course agent was called
    expect(mockCourseAgent.createCourse).toHaveBeenCalled();
    
    // Verify user agent was called
    expect(mockUserAgent.enrollUsers).toHaveBeenCalled();
    
    expect(result.success).toBe(true);
  });
});
```

## Best Practices

### 1. Single Responsibility

Each agent should focus on one domain:

```typescript
// ✅ Good: Focused agent
class UserAgent extends BaseAgent {
  // Only handles user-related operations
}

// ❌ Bad: Too broad
class EverythingAgent extends BaseAgent {
  // Handles users, courses, content, etc.
}
```

### 2. Clear Error Messages

Provide helpful, actionable error messages:

```typescript
// ✅ Good
return {
  success: false,
  message: 'Cannot create user: email "invalid-email" is not valid. Please provide a valid email address.',
  suggestions: ['Check email format', 'Verify email domain']
};

// ❌ Bad
return {
  success: false,
  message: 'Error'
};
```

### 3. Validate Early

Validate inputs before planning or execution:

```typescript
private async createUser(intent: Intent, context: Context): Promise<AgentResponse> {
  // Validate immediately
  const validation = this.validateUserInput(intent.parameters);
  if (!validation.isValid) {
    return {
      success: false,
      message: validation.errors.join(', '),
      requiresConfirmation: false
    };
  }
  
  // Proceed with execution
  // ...
}
```

### 4. Log Everything

Comprehensive logging for debugging and audit:

```typescript
private async executeStep(step: TaskStep, context: Context): Promise<StepResult> {
  this.logger.info('Executing step', {
    stepId: step.id,
    tool: step.tool,
    parameters: this.sanitizeForLogging(step.parameters),
    userId: context.userId
  });
  
  try {
    const result = await this.executeStepInternal(step, context);
    
    this.logger.info('Step completed', {
      stepId: step.id,
      success: result.success
    });
    
    return result;
  } catch (error) {
    this.logger.error('Step failed', {
      stepId: step.id,
      error: error.message,
      stack: error.stack
    });
    throw error;
  }
}
```

### 5. Require Confirmation for Critical Actions

```typescript
private shouldRequireConfirmation(plan: TaskPlan): boolean {
  // Require confirmation for:
  // - High-risk operations
  // - Bulk operations affecting many entities
  // - Destructive operations
  // - Operations affecting system configuration
  
  if (plan.riskLevel === 'high') return true;
  if (plan.steps.some(s => s.action.includes('delete'))) return true;
  if (plan.steps.some(s => s.action.includes('bulk'))) return true;
  
  return false;
}
```

### 6. Implement Rollback

Always have a rollback plan for critical operations:

```typescript
protected async createRollbackPlan(plan: TaskPlan): Promise<RollbackPlan> {
  const rollbackSteps: RollbackStep[] = [];
  
  for (const step of plan.steps) {
    if (this.isReversible(step)) {
      rollbackSteps.unshift({  // Reverse order
        action: `undo_${step.action}`,
        tool: `rollback_${step.tool}`,
        parameters: {
          originalStepId: step.id,
          originalResult: step.result
        }
      });
    }
  }
  
  return {
    steps: rollbackSteps,
    canRollback: rollbackSteps.length > 0
  };
}
```

## Advanced Patterns

### 1. Agent Composition

Agents can call other agents for complex workflows:

```typescript
class CourseAgent extends BaseAgent {
  private userAgent: UserAgent;
  private contentAgent: ContentAgent;
  
  async setupCourse(intent: Intent, context: Context): Promise<AgentResponse> {
    // Use UserAgent to enroll students
    const enrollmentIntent = {
      action: 'enroll_users',
      parameters: { courseId: intent.parameters.courseId, userIds: [...] }
    };
    const enrollmentResult = await this.userAgent.processIntent(
      enrollmentIntent, 
      context
    );
    
    // Use ContentAgent to organize materials
    const contentIntent = {
      action: 'organize_content',
      parameters: { courseId: intent.parameters.courseId }
    };
    const contentResult = await this.contentAgent.processIntent(
      contentIntent, 
      context
    );
    
    return {
      success: enrollmentResult.success && contentResult.success,
      message: 'Course setup completed',
      data: { enrollment: enrollmentResult.data, content: contentResult.data }
    };
  }
}
```

### 2. Proactive Suggestions

Agents can generate proactive suggestions:

```typescript
class UserAgent extends BaseAgent {
  async generateSuggestions(context: Context): Promise<Suggestion[]> {
    const suggestions: Suggestion[] = [];
    
    // Analyze user data
    const inactiveUsers = await this.findInactiveUsers(30);
    if (inactiveUsers.length > 0) {
      suggestions.push({
        type: 'action',
        priority: 'medium',
        title: `${inactiveUsers.length} users haven't logged in 30+ days`,
        description: 'Consider sending reminder emails or suspending accounts',
        actions: [
          {
            label: 'Send Reminders',
            intent: {
              action: 'send_reminders',
              parameters: { userIds: inactiveUsers.map(u => u.id) }
            }
          },
          {
            label: 'Suspend Accounts',
            intent: {
              action: 'suspend_users',
              parameters: { userIds: inactiveUsers.map(u => u.id) }
            }
          }
        ]
      });
    }
    
    return suggestions;
  }
}
```

### 3. Learning from Patterns

Agents can learn from admin behavior:

```typescript
class CourseAgent extends BaseAgent {
  private patternLearner: PatternLearner;
  
  async createCourse(intent: Intent, context: Context): Promise<AgentResponse> {
    // Learn from previous course creations
    const similarCourses = await this.patternLearner.findSimilar(
      intent.parameters,
      context.userId
    );
    
    if (similarCourses.length > 0) {
      // Suggest using a template
      return {
        success: false,
        requiresConfirmation: false,
        message: 'I found similar courses you created. Would you like to use a template?',
        suggestions: similarCourses.map(course => ({
          label: `Use "${course.title}" as template`,
          intent: {
            action: 'create_from_template',
            parameters: { templateId: course.id, ...intent.parameters }
          }
        }))
      };
    }
    
    // Proceed with normal creation
    // ...
  }
}
```

## Troubleshooting

### Common Issues

#### 1. Agent Not Responding

**Symptoms**: Agent doesn't process intents or returns errors

**Solutions**:
- Check agent registration in registry
- Verify LLM client configuration
- Check logs for errors
- Ensure tools are properly loaded

#### 2. Permission Errors

**Symptoms**: "Insufficient permissions" errors

**Solutions**:
- Verify user permissions in context
- Check agent's required permissions
- Review permission checks in tools

#### 3. LLM Timeout

**Symptoms**: Planning or generation takes too long

**Solutions**:
- Increase timeout settings
- Optimize prompts (shorter, more focused)
- Use caching for common queries
- Consider using faster/smaller models for simple tasks

#### 4. Plan Execution Fails

**Symptoms**: Steps in plan fail unexpectedly

**Solutions**:
- Add more validation before execution
- Improve error handling in tools
- Add retry logic for transient failures
- Review step dependencies

### Debugging Tips

1. **Enable Verbose Logging**:
```typescript
this.logger.setLevel('debug');
```

2. **Inspect Intent Parsing**:
```typescript
console.log('Parsed intent:', JSON.stringify(intent, null, 2));
```

3. **Trace Plan Execution**:
```typescript
this.logger.debug('Execution plan', {
  steps: plan.steps.map(s => ({
    id: s.id,
    tool: s.tool,
    parameters: s.parameters
  }))
});
```

4. **Monitor Tool Calls**:
```typescript
// Add logging in tool.execute()
async execute(params: any, context: Context): Promise<ToolResult> {
  this.logger.debug('Tool execution', { tool: this.name, params });
  // ... execution
}
```

## Example: Complete Agent Implementation

Here's a complete example of a simple agent:

```typescript
// agents/notification-agent.ts
import { BaseAgent, Intent, Context, AgentResponse } from '../core/agent';
import { NotificationService } from '../services/notification-service';
import { SendEmailTool, SendSmsTool } from '../tools/notification-tools';

export class NotificationAgent extends BaseAgent {
  private notificationService: NotificationService;
  
  constructor(config: AgentConfig) {
    super(config);
    this.agentType = 'notification';
    this.notificationService = new NotificationService();
    this.loadTools();
  }
  
  protected loadTools(): void {
    this.tools.set('send_email', new SendEmailTool());
    this.tools.set('send_sms', new SendSmsTool());
  }
  
  async processIntent(intent: Intent, context: Context): Promise<AgentResponse> {
    try {
      switch (intent.action) {
        case 'send_notification':
          return await this.sendNotification(intent, context);
        case 'send_bulk_notification':
          return await this.sendBulkNotification(intent, context);
        default:
          return {
            success: false,
            message: `Unsupported action: ${intent.action}`,
            requiresConfirmation: false
          };
      }
    } catch (error) {
      return await this.handleError(error, intent, context);
    }
  }
  
  private async sendNotification(
    intent: Intent, 
    context: Context
  ): Promise<AgentResponse> {
    const { recipient, message, channel } = intent.parameters;
    
    // Validate
    if (!recipient || !message) {
      return {
        success: false,
        message: 'Recipient and message are required',
        requiresConfirmation: false
      };
    }
    
    // Determine tool based on channel
    const toolName = channel === 'sms' ? 'send_sms' : 'send_email';
    const tool = this.tools.get(toolName);
    
    if (!tool) {
      return {
        success: false,
        message: `Channel ${channel} not supported`,
        requiresConfirmation: false
      };
    }
    
    // Execute
    const result = await tool.execute(
      { recipient, message },
      context
    );
    
    // Log
    await this.logAction({
      action: 'send_notification',
      userId: context.userId,
      details: { recipient, channel }
    });
    
    return {
      success: result.success,
      message: result.message || 'Notification sent successfully',
      data: result.data,
      requiresConfirmation: false
    };
  }
  
  private async sendBulkNotification(
    intent: Intent, 
    context: Context
  ): Promise<AgentResponse> {
    const { recipients, message, channel } = intent.parameters;
    
    if (!recipients || recipients.length === 0) {
      return {
        success: false,
        message: 'At least one recipient is required',
        requiresConfirmation: false
      };
    }
    
    // For bulk operations, require confirmation
    if (recipients.length > 10) {
      return {
        success: false,
        requiresConfirmation: true,
        confirmationDetails: {
          summary: `Send ${channel} notification to ${recipients.length} recipients`,
          estimatedImpact: `${recipients.length} notifications will be sent`,
          plan: {
            steps: [{
              id: 'bulk_send',
              action: 'send_bulk_notification',
              tool: channel === 'sms' ? 'send_sms' : 'send_email',
              parameters: { recipients, message },
              dependencies: [],
              retryable: true
            }],
            riskLevel: 'medium'
          }
        }
      };
    }
    
    // Execute for small batches
    const toolName = channel === 'sms' ? 'send_sms' : 'send_email';
    const tool = this.tools.get(toolName);
    
    const results = await Promise.all(
      recipients.map(recipient => 
        tool.execute({ recipient, message }, context)
      )
    );
    
    const successCount = results.filter(r => r.success).length;
    
    return {
      success: successCount === recipients.length,
      message: `Sent ${successCount}/${recipients.length} notifications`,
      data: { results },
      requiresConfirmation: false
    };
  }
}
```

## Next Steps

1. **Review Existing Agents**: Study the UserAgent and CourseAgent implementations
2. **Create Your Agent**: Follow the steps in "Creating Your First Agent"
3. **Write Tests**: Create comprehensive unit and integration tests
4. **Document Your Agent**: Add documentation for supported intents and tools
5. **Submit for Review**: Create a pull request with your agent implementation

## Additional Resources

- [Design Document](../DESIGN.md) - Overall system design
- [Technical Specification](./TECHNICAL_SPEC.md) - Technical details
- [API Documentation](./API.md) - API endpoints
- [Deployment Guide](./DEPLOYMENT.md) - Deployment instructions

---

**Last Updated**: January 26, 2026  
**Version**: 1.0
