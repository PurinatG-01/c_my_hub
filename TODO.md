# C My Hub - TODO List

**Last Updated**: 2025-11-21  
**Status**: Project requires fixes before production deployment

## 🚨 Critical - Blocking Issues (Fix Immediately)

### 1. Fix Compilation Errors
- [ ] **Replace deprecated `CardThemeData` with `CardTheme`**
  - Location: `frontend/lib/core/theme/app_theme.dart` (lines 41 and 120)
  - Error: `The name 'CardThemeData' isn't a class`
  - Action: Change `const CardThemeData(...)` to `CardTheme(...)`
  - Impact: Project won't compile until fixed
  - Estimated Time: 5 minutes

## 🔴 High Priority

### 2. Update Outdated Dependencies
- [ ] **Update Flutter dependencies to latest versions**
  - Run: `cd frontend && flutter pub upgrade --major-versions`
  - Review breaking changes for:
    - `flutter_riverpod: 2.6.1` → `3.0.3` (MAJOR version change)
    - `go_router: 14.8.1` → `17.0.0` (MAJOR version change)
    - `flutter_lints: 4.0.0` → `6.0.0`
    - `flutter_dotenv: 5.2.1` → `6.0.0`
  - Test thoroughly after upgrade
  - Update code to handle breaking changes
  - Estimated Time: 2-4 hours

### 3. Fix Code Style Issues
- [ ] **Fix unnecessary brace in string interpolation**
  - Location: `frontend/lib/features/dashboard/presentation/dashboard_screen.dart` (line 169)
  - Change: `"${variable}"` → `"$variable"`
  - Estimated Time: 2 minutes

## 🟡 Medium Priority

### 4. Remove Code Duplication
- [ ] **Delete duplicate HealthService file**
  - Remove: `frontend/lib/features/health/data/health_service.dart`
  - Keep: `frontend/lib/service/health_service.dart`
  - Verify no imports reference the deleted file
  - Run tests after deletion
  - Estimated Time: 10 minutes

### 5. Implement Unit Tests
- [ ] **Add comprehensive test coverage**
  - Current state: Only default `widget_test.dart` exists
  - Add tests for:
    - Health service logic
    - Dashboard providers/controllers
    - AI assistant service
    - Theme switching functionality
    - Navigation/routing
  - Target: Minimum 70% code coverage
  - Estimated Time: 8-12 hours

### 6. Backend Implementation Review
- [ ] **Verify backend functionality**
  - Current state: `backend/` directory only contains README and Supabase config
  - Check if Node.js/Express backend needs implementation
  - Verify Supabase Edge Functions are properly set up
  - Document actual backend architecture
  - Estimated Time: 1-2 hours (investigation)

## 🟢 Low Priority

### 7. Environment Setup
- [ ] **Accept Android licenses**
  - Run: `flutter doctor --android-licenses`
  - Accept all licenses
  - Estimated Time: 5 minutes

### 8. Update Flutter SDK
- [ ] **Upgrade Flutter to latest stable version**
  - Current: Flutter 3.22.2
  - Run: `flutter upgrade`
  - Test app after upgrade
  - Estimated Time: 15 minutes

### 9. Documentation Updates
- [ ] **Review and update documentation**
  - Verify accuracy of all docs in `docs/` directory
  - Update based on current project state
  - Remove outdated information
  - Locations: `docs/ARCHITECTURE.md`, `docs/FEATURES.md`, etc.
  - Estimated Time: 2-3 hours

### 10. Address Analysis Recommendations
- [ ] **Review `ANALYSIS_AND_RECOMMENDATIONS.md` findings**
  - Verify hardcoded values issue (stepsGoal in DashboardScreen)
  - Improve error handling in `main.dart` for HealthService initialization
  - Consider separating UI and business logic in DashboardScreen
  - Make user settings configurable (store in SharedPreferences)
  - Estimated Time: 3-4 hours

## 📋 Verification Steps (After Fixes)

- [ ] Run `flutter analyze` - should pass with no errors
- [ ] Run `flutter test` - all tests should pass
- [ ] Run `flutter build apk --debug` - should build successfully
- [ ] Run `flutter build ios --debug --no-codesign` - should build successfully
- [ ] Verify CI/CD pipeline passes (GitHub Actions)
- [ ] Manual testing on iOS and Android devices

## 📊 Estimated Total Time
- **Critical**: 5 minutes
- **High Priority**: 2-4 hours
- **Medium Priority**: 9-14 hours
- **Low Priority**: 6-9 hours
- **Total**: 17-27 hours

## 🔗 Related Files
- Analysis: `/ANALYSIS_AND_RECOMMENDATIONS.md`
- Main README: `/README.md`
- Frontend: `/frontend/`
- Backend: `/backend/`
- CI/CD: `/.github/workflows/`

## 📝 Notes
- Project uses FVM for Flutter version management
- Monorepo structure with frontend (Flutter) and backend (Supabase)
- CI/CD will fail until compilation errors are fixed
- Breaking changes in major dependency updates require careful migration
- Current branch: `feat/chat-kit-function` (has uncommitted changes)
