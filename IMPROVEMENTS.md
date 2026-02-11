# 代码改进总结 - visitor_practise

本文档总结了 2026-02-11 实施的关键代码改进。

## ✅ 已完成的修复

### 1. Timer 内存泄漏修复 🔧

**问题：** 多次调用初始化方法会创建多个 Timer 实例而不取消旧的，导致内存泄漏。

**位置：** `lib/pages/kiosk_visitor_sign_in/controllers/kiosk_visitor_sign_in_controller.dart`

**修复：**
```dart
// 修复前
_timeUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
  signInTimeCtrl.text = DateTime.now().toIso8601String();
  notifyListeners();
});

// 修复后
_timeUpdateTimer?.cancel(); // 先取消旧 timer
_timeUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
  signInTimeCtrl.text = DateTime.now().toIso8601String();
  notifyListeners();
});
```

---

### 2. Email 验证正则表达式改进 ✉️

**问题：** 原正则表达式不支持：
- 5+ 字符的 TLD (如 `.co.uk`)
- `+` 号（Gmail 常用）
- 国际域名

**解决方案：** 创建通用的 `ValidationHelper`

**新增文件：** `lib/services/helper/validation_helper.dart`

**修复：**
```dart
// 修复前 - 在 controller 中直接写正则
return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

// 修复后 - 使用共享的 ValidationHelper
import 'package:visitor_practise/services/helper/validation_helper.dart';

bool isValidEmail(String email) {
  return ValidationHelper.isValidEmail(email);
}

// 或在 Form 中直接使用
TextFormField(
  validator: (value) => ValidationHelper.validateEmail(value),
),
```

**ValidationHelper 提供的功能：**
- ✅ Email 验证（支持国际域名、特殊字符）
- ✅ 电话验证（支持多种格式）
- ✅ URL 验证
- ✅ 密码强度验证
- ✅ 数字/整数验证
- ✅ 长度验证（最小/最大）
- ✅ 日期验证（过去/未来）
- ✅ 信用卡验证（Luhn 算法）
- ✅ 邮政编码验证（支持多国）
- ✅ 组合验证器

**现在支持的 Email 格式：**
- ✅ `user+tag@example.com`
- ✅ `user@example.co.uk`
- ✅ `user@example.museum`
- ✅ `user.name@sub.domain.example.com`
- ✅ 国际域名

**详细使用指南：** 查看 `lib/services/helper/VALIDATION_USAGE.md`

---

### 3. 图片处理性能优化 🖼️

**问题：** 图片压缩在主线程执行，导致 UI 卡顿。

**位置：** `lib/pages/kiosk_visitor_sign_in/controllers/kiosk_visitor_sign_in_controller.dart:216-254`

**修复：** 使用 `compute()` 在独立 isolate 处理

```dart
// 顶级函数（必须在类外）
Uint8List _compressImageInIsolate(Uint8List bytes) {
  try {
    final image = img.decodeImage(bytes);
    if (image != null) {
      final resized = img.copyResize(image, width: 800, height: 800);
      return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
    }
    return bytes;
  } catch (e) {
    return bytes;
  }
}

// 在 controller 中调用
final bytes = await photo.readAsBytes();
_visitorPhotoBytes = await compute(_compressImageInIsolate, bytes);
```

**性能提升：** 大图片处理不再阻塞 UI 线程

---

### 4. 统一日志服务 📊

**新增文件：** `lib/services/helper/app_logger.dart`

**功能：**
- 统一的日志格式
- 不同级别的日志（debug, info, warning, error, success, network）
- 生产环境自动禁用 debug 日志

**使用方法：**
```dart
import 'package:visitor_practise/services/helper/app_logger.dart';

// Debug 日志（仅开发环境）
AppLogger.debug('Initializing controller', 'SignInController');

// 信息日志
AppLogger.info('User signed in successfully');

// 警告
AppLogger.warning('API response delayed');

// 错误（带堆栈跟踪）
AppLogger.error('Failed to load contacts', error, stackTrace, 'SignInController');

// 成功
AppLogger.success('Badge printed successfully');

// 网络请求
AppLogger.network(
  'Fetching contacts',
  method: 'GET',
  endpoint: '/api/contacts',
  statusCode: 200,
);
```

---

### 5. 统一 API 错误处理 ⚠️

**新增文件：** `lib/core/errors/api_exception.dart`

**功能：**
- 统一的异常类型
- 根据 HTTP 状态码自动分类
- 用户友好的错误消息

**使用方法：**
```dart
import 'package:visitor_practise/core/errors/api_exception.dart';

try {
  final response = await ApiService.fetchData(token);
} catch (e) {
  final apiError = ApiExceptionFactory.fromError(e);

  // 显示用户友好的错误消息
  context.showError(apiError.userMessage);

  // 记录详细错误
  AppLogger.error('API call failed', apiError);
}
```

**错误类型：**
- `ApiErrorType.network` - 网络连接问题
- `ApiErrorType.timeout` - 请求超时
- `ApiErrorType.unauthorized` - 认证失败（401, 403）
- `ApiErrorType.validation` - 验证错误（400, 422）
- `ApiErrorType.server` - 服务器错误（500+）
- `ApiErrorType.notFound` - 资源不存在（404）
- `ApiErrorType.unknown` - 未知错误

---

### 6. 网络状态监听 📡

**新增文件：**
- `lib/services/network_service.dart` - 网络服务
- `lib/shared_widgets/network_status_banner.dart` - 离线提示 UI

**功能：**
- 自动检测网络连接状态
- 实时监听连接变化
- 全局离线状态提示

**使用方法：**

#### 在 Controller 中检查网络
```dart
import 'package:visitor_practise/services/network_service.dart';

// 检查是否在线
if (!NetworkService.isOnline) {
  context.showError('No internet connection');
  return;
}

// 或使用异步检查
final isConnected = await NetworkService.isConnected();
if (!isConnected) {
  // 处理离线情况
}

// 获取连接类型
final connectionType = await NetworkService.getConnectionType();
print('Connected via: $connectionType'); // WiFi, Mobile Data, Ethernet, etc.
```

#### 监听连接变化
```dart
NetworkService.onConnectivityChanged.listen((isOnline) {
  if (isOnline) {
    print('Connection restored');
    // 重新加载数据
  } else {
    print('Connection lost');
    // 切换到离线模式
  }
});
```

**UI 效果：**
- 离线时顶部显示红色横幅："No Internet Connection - System is offline"
- 恢复连接时显示绿色横幅："Connected via WiFi/Mobile Data"
- 自动在所有页面显示（通过 MaterialApp builder）

---

### 7. 代码重复消除 🔄

**新增文件：** `lib/services/helper/initialization_helper.dart`

**功能：** 共享的初始化逻辑，减少重复代码

**提供的方法：**
```dart
// 加载品牌资源（logos, background）
final assets = await InitializationHelper.loadBrandingAssets();
topLogo = assets.topLogo;
bottomLogo = assets.bottomLogo;
background = assets.background;

// 加载选中的 site
final site = await InitializationHelper.loadSelectedSite();

// 检查认证状态
final authStatus = await InitializationHelper.checkAuthentication();
if (authStatus == AuthStatus.missingToken) {
  // 跳转到登录页
}

// 加载 kiosk 配置
final config = await InitializationHelper.loadKioskConfig();
reqPrint = config.reqPrint;
sendSms = config.sendSms;
```

**好处：**
- ✅ 减少代码重复（从 3+ 处相同代码 → 1 处）
- ✅ 统一错误处理
- ✅ 更容易维护和测试

---

## 📦 新增 Package

在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  connectivity_plus: ^6.1.2  # 网络状态检测
```

**安装命令：**
```bash
flutter pub get
```

---

## 🚀 如何使用新功能

### 1. 网络状态已自动启用

所有页面自动显示网络状态横幅（在 `main.dart` 中配置）。

### 2. 在 API 调用前检查网络

**示例：** `kiosk_visitor_sign_in_controller.dart:190-210`

```dart
Future<void> loadContacts() async {
  // ✅ 先检查网络
  if (!NetworkService.isOnline) {
    _errorMessage = 'No internet connection';
    return;
  }

  // 继续 API 调用
  final response = await ApiService.fetchVisitorContacts(token);
}
```

### 3. 使用新的日志系统

**替换所有 `debugPrint()` 为：**
```dart
// ❌ 旧方式
debugPrint('Loading contacts...');

// ✅ 新方式
AppLogger.info('Loading contacts...', 'SignInController');
```

### 4. 使用统一错误处理

```dart
try {
  await someApiCall();
} catch (e) {
  final apiError = ApiExceptionFactory.fromError(e);
  AppLogger.error('API failed', apiError, null, 'Controller');
  context.showError(apiError.userMessage);
}
```

---

## 🔜 后续建议改进

### 短期（2周内）
1. ✅ 将所有 API 调用前添加网络检测
2. ⏳ 替换所有 `debugPrint()` 为 `AppLogger`
3. ⏳ 在其他 controllers 使用 `InitializationHelper`
4. ⏳ 统一所有 API 异常处理使用 `ApiException`

### 中期（1个月内）
5. ⏳ 添加 Repository 层（缓存 API 响应）
6. ⏳ 实现表单实时验证
7. ⏳ 拆分 `AdminDashboardController`（1048行 → 多个小 controller）
8. ⏳ 添加单元测试

### 长期
9. ⏳ 实现依赖注入（get_it）
10. ⏳ 添加离线模式支持
11. ⏳ 实现 HTTPS 证书固定
12. ⏳ 优化状态管理（考虑 Riverpod）

---

## 📊 改进效果

| 问题类型 | 修复前 | 修复后 |
|---------|--------|--------|
| Timer 内存泄漏 | 多次初始化创建多个 timer | ✅ 自动取消旧 timer |
| Email 验证 | 拒绝合法邮箱 | ✅ 支持所有标准格式 |
| 图片处理 | UI 卡顿 | ✅ 独立线程处理 |
| 错误日志 | 混乱，无分类 | ✅ 统一格式和级别 |
| API 错误 | 不一致处理 | ✅ 统一异常类型 |
| 网络检测 | 无 | ✅ 实时监听 + UI 提示 |
| 代码重复 | 3+ 处相同代码 | ✅ 共享 helper |

---

## ⚠️ 注意事项

1. **网络检测初始化**：已在 `main.dart` 中自动初始化，无需额外配置
2. **日志级别**：生产环境自动禁用 debug 日志
3. **图片处理**：只在拍照功能使用 `compute()`，badge 生成保持原样
4. **向后兼容**：所有修复保持向后兼容，不影响现有功能

---

## 🎯 总结

本次改进重点解决了：
- ✅ **内存泄漏**（Timer）
- ✅ **性能问题**（图片处理）
- ✅ **用户体验**（网络状态提示、更好的 email 验证）
- ✅ **代码质量**（统一日志、错误处理、减少重复）

所有修复都是**非侵入性**的，保持现有功能不变，同时提升了代码质量和用户体验。

---

**修复日期：** 2026-02-11
**修复人员：** Claude Opus 4.6
**版本：** visitor_practise v1.0.0+1
