# GitHub Actions Configuration Guide

## Workflows Overview

This repository includes two main GitHub Actions workflows:

### 1. PR Checks (`pr_checks.yml`)

**Primary workflow that must pass for PR approval**

- **Triggers**: Pull requests to `main` branch
- **Required checks**:
  - Code formatting (`dart format`)
  - Static analysis (`flutter analyze`)
  - Unit tests (`flutter test`)
  - Test coverage reporting
  - Mobile build verification (Android APK + iOS)
  - Security audit (`dart pub audit`)
  - Dependency validation

### 2. Advanced Analysis (`advanced_analysis.yml`)

**Informational workflow for code quality insights**

- **Triggers**: Pull requests to `main` branch
- **Analysis includes**:
  - Code metrics and complexity
  - Performance recommendations
  - TODO/FIXME tracking
  - Documentation coverage
  - License compliance

## Setting Up Branch Protection

To require these checks before merging PRs:

1. Go to your repository Settings → Branches
2. Add a branch protection rule for `main`
3. Enable "Require status checks to pass before merging"
4. Select these required status checks:
   - `Analyze & Test`
   - `Security & Dependencies`

## Workflow Features

### Automatic PR Comments

Both workflows automatically comment on PRs with:

- ✅ Success/failure status
- 📊 Analysis summaries
- 💡 Actionable recommendations
- 📈 Code quality metrics

### Performance Optimizations

- Dependency caching
- Concurrent job execution
- Smart cancellation of outdated runs
- Artifact retention (30 days)

### Security Features

- Dependency vulnerability scanning
- Outdated package detection
- License compliance checking
- No secrets in workflow files

## Local Development

Before pushing, run these commands locally:

```bash
# Format code
dart format .

# Run analysis
flutter analyze

# Run tests
flutter test

# Test mobile builds
flutter build apk --debug
flutter build ios --debug --no-codesign

# Check for outdated packages
flutter pub outdated

# Security audit
dart pub audit
```

## Customization

### Adjusting Flutter Version

Update the `flutter-version` in both workflows:

```yaml
- uses: subosito/flutter-action@v2
  with:
    flutter-version: "3.24.5" # Change this
```

### Adding Coverage Thresholds

Uncomment and modify the coverage check section in `pr_checks.yml`:

```yaml
# Example: Require 80% coverage
- name: Check coverage threshold
  run: |
    coverage=$(lcov --summary coverage/lcov.info | grep -oP 'lines......: \K\d+\.\d+')
    if (( $(echo "$coverage < 80.0" | bc -l) )); then
      echo "Coverage $coverage% is below 80% threshold"
      exit 1
    fi
```

### Custom Analysis Rules

Modify `analysis_options.yaml` to adjust linting rules:

```yaml
linter:
  rules:
    # Add your custom rules here
    prefer_single_quotes: true
    avoid_print: true
```

## Troubleshooting

### Common Issues

1. **Build failures**: Check Flutter version compatibility
2. **Test timeouts**: Increase timeout in test configuration
3. **Coverage issues**: Ensure test files are properly structured
4. **Dependency conflicts**: Run `flutter pub deps` locally

### Getting Help

- Check workflow logs in the Actions tab
- Review PR comments for specific issues
- Ensure local development setup matches CI environment
