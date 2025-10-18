---
name: clean-architecture-validator
description: Validates clean architecture boundaries and patterns. Use when modifying code in domain, data, or presentation layers, or when reviewing architecture compliance.
---

# Clean Architecture Validator

Enforces clean architecture principles across any codebase using layered architecture.

## Core Rules

### 1. Layer Dependency Rules - THE GOLDEN RULE

**Dependencies MUST flow in ONE direction: INWARD**

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│    (UI, Controllers, Providers)         │
│                                         │
│  Depends on ↓ (through interfaces)     │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│            Data Layer                   │
│   (Repositories Impl, DataSources)      │
│                                         │
│  Depends on ↓ (implements interfaces)  │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│          Domain Layer (CORE)            │
│   (Entities, UseCases, Interfaces)      │
│                                         │
│       NO DEPENDENCIES ⛔                 │
└─────────────────────────────────────────┘
```

**Layer Dependency Matrix:**

|                  | Can depend on Domain? | Can depend on Data? | Can depend on Presentation? |
|------------------|----------------------|---------------------|----------------------------|
| **Domain**       | ✅ Self only         | ❌ NEVER            | ❌ NEVER                   |
| **Data**         | ✅ YES (interfaces)  | ✅ Self only        | ❌ NEVER                   |
| **Presentation** | ✅ YES (interfaces)  | ❌ AVOID*           | ✅ Self only               |

*Presentation should depend on Domain abstractions, not Data directly.

**Critical Rules:**

1. **Domain is the CENTER** - Has ZERO external dependencies
   - No imports from data layer
   - No imports from presentation layer
   - No framework dependencies
   - Only pure language code + business logic

2. **Data depends on Domain ONLY through interfaces**
   - Implements repository interfaces defined in domain
   - Returns domain entities
   - Never exposes data models to domain

3. **Presentation depends on Domain ONLY through interfaces**
   - Uses domain entities for state
   - Calls domain usecases (injected via DI)
   - Never directly instantiates data layer classes

4. **ALL cross-layer dependencies MUST use:**
   - ✅ Interfaces/Abstractions (defined in domain)
   - ✅ Dependency Injection (constructor injection)
   - ❌ NEVER direct imports of concrete implementations
   - ❌ NEVER service locator in domain

**Dependency Flow Examples:**

✅ **CORRECT: One-way dependency through interfaces**
```
Presentation Layer:
├── ReportListPage
│   └── uses → ReportNotifier
│       └── depends on → GetAllReports (usecase from domain)
│           └── depends on → ReportRepository (interface from domain)
│
Data Layer:
├── ReportRepositoryImpl
│   └── implements → ReportRepository (interface from domain)
│   └── depends on → ReportLocalDataSource (interface from domain)
│
Domain Layer:
├── ReportRepository (interface)
├── GetAllReports (usecase)
└── Report (entity)
    └── NO EXTERNAL DEPENDENCIES
```

❌ **WRONG: Circular or reverse dependencies**
```
Domain Layer:
├── GetAllReports
│   └── imports → ReportRepositoryImpl (from data) ❌ VIOLATION!
│
Data Layer:
├── ReportRepositoryImpl
│   └── imports → ReportListPage (from presentation) ❌ VIOLATION!
```

**Enforcing One-Way Dependencies:**

1. **Domain Layer Isolation**
   ```
   RULE: Domain cannot import from data or presentation

   Violations to detect:
   - import '../data/...'
   - import '../presentation/...'
   - import 'package:framework/...' (Flutter, React, etc.)
   ```

2. **Data Layer Boundary**
   ```
   RULE: Data can only import domain interfaces

   ✅ Allowed:
   - import '../../domain/repositories/report_repository.dart'
   - import '../../domain/entities/report.dart'

   ❌ Forbidden:
   - import '../../presentation/...'
   - import from other data implementations directly
   ```

3. **Presentation Layer Boundary**
   ```
   RULE: Presentation uses domain through DI

   ✅ Allowed:
   - import '../../domain/usecases/get_all_reports.dart'
   - import '../../domain/entities/report.dart'
   - Inject usecases via DI container

   ❌ Forbidden:
   - import '../../data/repositories/report_repository_impl.dart'
   - Direct instantiation: ReportRepositoryImpl()
   ```

**Interface-Based Dependencies:**

ALL dependencies between layers MUST use interfaces:

```dart
// ✅ CORRECT: Domain defines interface
// domain/repositories/report_repository.dart
abstract class ReportRepository {
  Future<Either<Failure, List<Report>>> getAllReports();
}

// Data implements interface
// data/repositories/report_repository_impl.dart
class ReportRepositoryImpl implements ReportRepository {
  @override
  Future<Either<Failure, List<Report>>> getAllReports() {
    // Implementation
  }
}

// Presentation depends on interface (injected)
// presentation/providers/report_provider.dart
class ReportNotifier {
  final ReportRepository repository; // Interface, not impl!

  ReportNotifier({required this.repository});
}

// DI Container wires concrete implementation
// core/di/injection_container.dart
@LazySingleton(as: ReportRepository) // Binds impl to interface
class ReportRepositoryImpl implements ReportRepository { ... }
```

❌ **WRONG: Direct dependency on implementation**
```dart
// domain/usecases/get_reports.dart
import '../../data/repositories/report_repository_impl.dart'; // ❌

class GetAllReports {
  final ReportRepositoryImpl repository; // ❌ Concrete class!

  GetAllReports({required this.repository});
}
```

**Dependency Injection for Cross-Layer Communication:**

```
Layer Communication Flow:

Presentation Layer:
  └─> Retrieves usecase from DI container
      └─> Calls usecase.call()
          └─> Usecase uses injected repository (interface)
              └─> DI container provided concrete implementation
                  └─> Implementation (Data Layer) executes
                      └─> Returns domain entity
                          └─> Flows back up to Presentation
```

**Key Principle:** Presentation and Data both depend on Domain abstractions, but NOT on each other.

### 2. Directory Structure Patterns
Look for these common patterns (adjust based on language):
```
/domain/        (or /core/, /business/)
  /entities/
  /repositories/  (interfaces/abstractions)
  /usecases/

/data/          (or /infrastructure/, /adapters/)
  /models/
  /repositories/  (implementations)
  /datasources/

/presentation/  (or /ui/, /api/, /delivery/)
  /pages/
  /widgets/
  /controllers/
  /providers/
```

### 3. Repository Pattern Validation
- Domain defines abstract interfaces
- Data provides concrete implementations
- All repository methods should return consistent result types:
  - Either/Result types (functional approach)
  - Exceptions with try-catch (OOP approach)
  - Callbacks/promises (async patterns)

### 4. Entity Purity
Domain entities should be:
- Framework-agnostic (pure language code)
- Immutable when possible
- Free from external dependencies
- Contain business logic only

### 5. Dependency Injection & Inversion

**Dependency Inversion Principle (DIP):**
- High-level modules (domain) should NOT depend on low-level modules (data/infrastructure)
- Both should depend on abstractions (interfaces/protocols)
- Abstractions should NOT depend on details
- Details should depend on abstractions

**Constructor Injection Pattern:**
```
✅ CORRECT: Dependencies injected via constructor
class SaveReport {
  final ReportRepository repository;  // Interface from domain

  SaveReport({required this.repository});

  Future<Either<Failure, void>> call(Report report) {
    return repository.save(report);
  }
}

❌ WRONG: Direct instantiation (tight coupling)
class SaveReport {
  final ReportRepository repository = ReportRepositoryImpl();  // Concrete class!
}

❌ WRONG: Service locator in domain
class SaveReport {
  Future<Either<Failure, void>> call(Report report) {
    final repo = getIt<ReportRepository>();  // Service locator anti-pattern!
  }
}
```

**DI Container Usage Rules:**

*Domain Layer:*
- ✅ Accept dependencies via constructor
- ✅ Depend on interfaces/abstractions only
- ❌ NEVER import DI container (get_it, InversifyJS, Spring, etc.)
- ❌ NEVER use service locator pattern
- ❌ NEVER instantiate concrete implementations

*Data Layer:*
- ✅ Register implementations with DI container
- ✅ Accept dependencies via constructor
- ✅ Implement interfaces from domain

*Presentation Layer:*
- ✅ Retrieve dependencies from DI container (providers, controllers)
- ✅ Pass dependencies to domain usecases
- ❌ Avoid passing presentation dependencies to domain

**DI Framework Detection (Language-Specific):**

- **Dart/Flutter**: `get_it`, `injectable`, `riverpod` (providers)
  - Domain: No `getIt<>()` calls
  - Data: `@LazySingleton(as: Interface)` or `@injectable`
  - Presentation: Providers use `getIt<>()` to resolve

- **TypeScript/JavaScript**: `InversifyJS`, `tsyringe`, `awilix`
  - Domain: Pure classes with constructor injection
  - Infrastructure: `@injectable()` decorators
  - Presentation: Container.get() or inject()

- **Java/Kotlin**: `Spring`, `Dagger`, `Hilt`, `Koin`
  - Domain: No `@Autowired` or `@Inject` annotations
  - Data: `@Component`, `@Service`, `@Repository`
  - Presentation: `@Autowired` or constructor injection

- **C#**: Built-in DI, `Autofac`, `Ninject`
  - Domain: Plain constructors
  - Infrastructure: Interface bindings in Startup.cs
  - Presentation: Constructor injection via framework

- **Python**: `dependency_injector`, `injector`, `fastapi.Depends`
  - Domain: Type hints with abstractions
  - Infrastructure: Bindings/providers
  - Presentation: Dependency injection via framework

- **Go**: Manual DI (wire), `fx`, `dig`
  - Domain: Struct with interface fields
  - Infrastructure: Constructor functions
  - Main: Wire everything together

**Validation Checks for DI:**

1. **Service Locator Detection in Domain**
   ```
   Scan domain files for:
   - getIt<T>()
   - container.resolve()
   - ServiceLocator.get()
   - @Inject annotations (Java/Kotlin)

   Flag as violation: "Use constructor injection instead"
   ```

2. **Concrete Implementation Usage**
   ```
   Scan domain usecases/services for:
   - Direct instantiation of data layer classes
   - Imports from data/ layer

   Flag: "Depend on interfaces, inject via constructor"
   ```

3. **Missing Constructor Injection**
   ```
   Check domain classes have:
   - Constructor parameters for dependencies
   - Final/readonly fields
   - No static dependencies
   ```

4. **DI Registration Validation**
   ```
   Check data layer classes:
   - Implement domain interfaces
   - Registered with DI container
   - Use correct scope (singleton, transient, scoped)
   ```

**Common DI Anti-Patterns:**

❌ **Service Locator in Domain**
```dart
// BAD: Domain depending on DI container
class SaveReport {
  Future<void> call(Report report) {
    final repo = getIt<ReportRepository>();  // Tight coupling!
    return repo.save(report);
  }
}
```

❌ **God Object DI Container**
```typescript
// BAD: Passing entire container
class UserService {
  constructor(private container: Container) {}

  async getUser(id: string) {
    // Service fetching dependencies on demand
    const repo = this.container.get<UserRepository>();
  }
}
```

❌ **Mixed Concerns**
```python
# BAD: Domain class with DI annotations
@injectable  # Framework-specific annotation!
class CreateUser:
    def __init__(self, repo: UserRepository):
        self.repo = repo
```

✅ **Correct Pattern:**
```dart
// GOOD: Pure constructor injection
class SaveReport {
  final ReportRepository repository;

  SaveReport({required this.repository});

  Future<Either<Failure, void>> call(Report report) {
    return repository.save(report);
  }
}

// DI registration happens in infrastructure/presentation
@LazySingleton(as: ReportRepository)
class ReportRepositoryImpl implements ReportRepository {
  // ...
}
```

## Validation Checks

### When User Modifies Files

1. **Check One-Way Dependency Flow**
   ```
   For EVERY file modification:

   If file is in domain/:
     - Scan for ANY imports from ../data/ or ../presentation/
     - Scan for framework imports (Flutter, React, Spring, etc.)
     - Flag violations immediately with "Domain must have ZERO outward dependencies"
     - Verify all dependencies are pure language types

   If file is in data/:
     - Scan for imports from ../presentation/
     - Flag: "Data cannot depend on Presentation"
     - Verify only imports from ../domain/ (interfaces/entities)
     - Check for imports of concrete classes from other data modules

   If file is in presentation/:
     - Scan for imports from ../data/ (concrete implementations)
     - Flag: "Presentation should depend on Domain interfaces, not Data implementations"
     - Verify usecases/repositories accessed via DI, not direct imports
   ```

2. **Check Interface-Based Dependencies**
   ```
   For files with dependencies:

   - Scan constructor parameters
   - Verify dependency types are interfaces/abstractions
   - Flag concrete class types (ending in Impl, Implementation, etc.)
   - Ensure dependencies defined in domain layer

   Example violations:
   ❌ final ReportRepositoryImpl repository;
   ✅ final ReportRepository repository;

   ❌ final HiveDatabase database;
   ✅ final LocalDataSource dataSource;
   ```

3. **Check Repository Implementations**
   ```
   If file matches *_repository*:
     - Verify interface exists in domain/
     - Verify implementation in data/
     - Check method signatures match
     - Verify error handling pattern
     - Ensure repository interface has no concrete type dependencies
   ```

4. **Check Entity Dependencies**
   ```
   If file in domain/entities/:
     - Verify no framework imports
     - Check for pure language types only
     - Warn if mutable state detected
     - Ensure entity has NO dependencies on other layers
   ```

5. **Check Dependency Injection Violations**
   ```
   If file in domain/usecases/ or domain/services/:
     - Scan for service locator patterns (getIt, container.get, etc.)
     - Check for direct instantiation of concrete classes
     - Verify constructor injection pattern
     - Ensure dependencies are abstractions (interfaces)

   If file in data/repositories/:
     - Verify implements interface from domain
     - Check for DI registration annotations
     - Validate constructor accepts injected dependencies
   ```

### Language-Specific Patterns

**Detect by file extension or project structure:**

- **Dart/Flutter**: Look for `package:flutter`, `package:hive`, `package:dio` in domain
- **TypeScript/JS**: Look for `express`, `react`, `prisma` imports in domain
- **Java/Kotlin**: Look for `javax.persistence`, `android.*`, `spring.*` in domain
- **Python**: Look for `django`, `flask`, `sqlalchemy` in domain
- **Go**: Look for framework packages in domain layer
- **C#**: Look for `EntityFramework`, `ASP.NET` in domain

## When to Run

Use this skill when:
- User creates or modifies files in domain/, data/, or presentation/
- User asks "is this clean architecture?"
- User requests architecture review
- User commits code (proactive check)

## Response Format

**If violations found:**

*Example 1: Reverse Dependency (Domain → Data)*
```
🚨 Architecture Violation Detected

File: domain/usecases/get_reports.dart
Issue: REVERSE DEPENDENCY - Domain depending on Data layer

Line 3: import '../../data/repositories/report_repository_impl.dart'

Rule: Dependencies must flow INWARD (Presentation → Data → Domain)
      Domain cannot depend on Data or Presentation layers.

Fix:
1. Define interface in domain: ReportRepository (abstract class)
2. Import interface: import '../repositories/report_repository.dart'
3. Depend on abstraction, not implementation
4. Let DI container provide concrete implementation

Impact: Violates Dependency Inversion Principle (DIP)
```

*Example 2: Layer Crossing (Presentation → Data)*
```
🚨 Architecture Violation Detected

File: presentation/providers/report_provider.dart
Issue: Skipping abstraction layer - Direct dependency on Data

Line 5: import '../../data/repositories/report_repository_impl.dart'
Line 12: final repo = ReportRepositoryImpl();

Rule: Presentation must depend on Domain interfaces, NOT Data implementations.
      Dependencies: Presentation → Domain ← Data

Fix:
1. Import domain interface: import '../../domain/repositories/report_repository.dart'
2. Change type: final ReportRepository repository;
3. Inject via constructor
4. Use DI container to resolve implementation

Why: Allows swapping implementations without changing presentation code.
```

*Example 3: Framework Import in Domain*
```
🚨 Architecture Violation Detected

File: domain/entities/user.dart
Issue: Framework dependency in Domain layer

Line 3: import 'package:flutter/material.dart'

Rule: Domain must have ZERO external dependencies.
      Domain is the CENTER - pure business logic only.

Fix: Remove Flutter import. Use pure Dart types only.

Impact: Makes domain non-portable and framework-coupled.
```

*Example 4: Service Locator in Domain*
```
🚨 Architecture Violation Detected

File: domain/usecases/save_report.dart
Issue: Service locator pattern breaks constructor injection

Line 12: final repo = getIt<ReportRepository>();

Rule: Domain must use constructor injection, NOT service locator.
      Dependencies should be explicit via constructor parameters.

Fix:
1. Add constructor parameter: final ReportRepository repository;
2. Remove getIt call
3. Use injected repository instance

Why: Service locator hides dependencies and violates DI principles.
```

*Example 5: Concrete Implementation Dependency*
```
🚨 Architecture Violation Detected

File: domain/usecases/get_reports.dart
Issue: Depending on concrete implementation instead of abstraction

Line 5: import '../../data/repositories/report_repository_impl.dart'
Line 10: final ReportRepositoryImpl repository;

Rule: Domain must depend on ABSTRACTIONS only (interfaces).
      "Depend on abstractions, not concretions" - Dependency Inversion Principle

Fix:
1. Define/import interface: import '../repositories/report_repository.dart'
2. Change type: final ReportRepository repository;
3. Accept via constructor injection
4. Remove any direct instantiation

Why: Allows multiple implementations (mock, prod, test) without changing domain code.
```

**If architecture is valid:**
```
✅ Clean Architecture Validated

All layers respect dependency boundaries.

Dependency Flow: ✓ ONE-WAY INWARD
  Presentation → Domain ← Data

Layer Boundaries: ✓ RESPECTED
  ✓ Domain has ZERO outward dependencies
  ✓ Data depends only on Domain interfaces
  ✓ Presentation depends only on Domain interfaces

Dependency Injection: ✓ PROPER
  ✓ Constructor injection used throughout
  ✓ No service locator in domain layer
  ✓ All dependencies are abstractions/interfaces

Entity Purity: ✓ MAINTAINED
  ✓ Entities are framework-agnostic
  ✓ No external dependencies in domain
  ✓ Pure business logic only
```

## Allowed Tools

Only use read-only tools for validation:
- Read files
- Grep for imports
- Glob for file patterns

Do NOT auto-fix violations - always ask user first.
