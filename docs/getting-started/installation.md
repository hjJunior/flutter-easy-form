# Installation

Not on pub.dev yet (still `0.1.0-beta`) — add it as a git dependency,
pointing at the package's subdirectory in this repo:

```yaml
dependencies:
  flutter_easy_form:
    git:
      url: https://github.com/hjJunior/flutter-easy-form.git
      ref: v2-beta
      path: easy_form
```

Then import it wherever you declare a form or bind a widget:

```dart
import 'package:flutter_easy_form/flutter_easy_form.dart';
```

Next: [building your first form](building-your-first-form.md).
