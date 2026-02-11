# ✅ ValidationHelper 已创建完成

Email 验证现在已经做成通用的 Helper！

## 📁 新增文件

1. **`lib/services/helper/validation_helper.dart`**
   - 通用验证工具类
   - 20+ 种验证方法
   - 所有验证逻辑集中管理

2. **`lib/services/helper/VALIDATION_USAGE.md`**
   - 完整的使用指南
   - 所有验证方法的示例
   - 最佳实践和迁移指南

## 🔄 已更新文件

- **`lib/pages/kiosk_visitor_sign_in/controllers/kiosk_visitor_sign_in_controller.dart`**
  - 现在使用 `ValidationHelper.isValidEmail()` 代替本地实现

## 📚 ValidationHelper 提供的验证方法

### ✉️ Email & 联系方式
- `isValidEmail()` - Email 格式验证（支持国际域名、特殊字符）
- `validateEmail()` - Email 验证并返回错误消息
- `isValidPhone()` - 电话号码验证
- `validatePhone()` - 电话验证并返回错误消息

### 📝 基础验证
- `validateRequired()` - 必填字段
- `validateMinLength()` - 最小长度
- `validateMaxLength()` - 最大长度

### 🔢 数字验证
- `isNumeric()` - 是否为数字
- `validateNumeric()` - 数字验证
- `isInteger()` - 是否为整数
- `validateInteger()` - 整数验证
- `validateRange()` - 数字范围验证

### 🔒 安全验证
- `isStrongPassword()` - 强密码检查
- `validatePassword()` - 密码验证
- `validatePasswordMatch()` - 密码匹配验证
- `isValidCreditCard()` - 信用卡验证（Luhn 算法）

### 🌐 其他验证
- `isValidUrl()` - URL 验证
- `validateUrl()` - URL 验证并返回错误消息
- `isValidDate()` - 日期格式验证
- `validateFutureDate()` - 未来日期验证
- `validatePastDate()` - 过去日期验证
- `isValidPostalCode()` - 邮政编码验证（支持多国）
- `isAlphabetic()` - 只允许字母
- `isAlphanumeric()` - 只允许字母和数字

### 🔗 高级功能
- `combineValidators()` - 组合多个验证器

## 💡 快速使用

### 在 Form 中验证 Email

```dart
import 'package:visitor_practise/services/helper/validation_helper.dart';

TextFormField(
  controller: emailController,
  decoration: const InputDecoration(labelText: 'Email'),
  validator: (value) => ValidationHelper.validateEmail(value),
  autovalidateMode: AutovalidateMode.onUserInteraction,
),
```

### 在 Controller 中验证

```dart
import 'package:visitor_practise/services/helper/validation_helper.dart';

Future<bool> validateForm(BuildContext context) async {
  // Email 验证
  if (!ValidationHelper.isValidEmail(emailCtrl.text.trim())) {
    context.showError('Invalid email format');
    return false;
  }

  // Phone 验证（可选）
  if (phoneCtrl.text.isNotEmpty) {
    final phoneError = ValidationHelper.validatePhone(
      phoneCtrl.text,
      required: false,
    );
    if (phoneError != null) {
      context.showError(phoneError);
      return false;
    }
  }

  return true;
}
```

### 组合多个验证

```dart
TextFormField(
  validator: (value) => ValidationHelper.combineValidators(
    value,
    [
      (v) => ValidationHelper.validateRequired(v, 'Email'),
      (v) => ValidationHelper.validateEmail(v),
      (v) => ValidationHelper.validateMaxLength(v, 100, 'Email'),
    ],
  ),
),
```

## 📖 完整文档

查看详细的使用指南和所有示例：
**`lib/services/helper/VALIDATION_USAGE.md`**

## ✨ 优势

| 之前 | 现在 |
|------|------|
| ❌ Email 验证逻辑分散在多个文件 | ✅ 统一在 ValidationHelper 中 |
| ❌ 不支持国际域名 | ✅ 支持所有标准格式 |
| ❌ 需要重复编写验证代码 | ✅ 一行代码调用 |
| ❌ 难以测试和维护 | ✅ 集中管理，易于测试 |
| ❌ 错误消息不一致 | ✅ 统一的错误消息 |

## 🎯 实际应用

目前已在以下地方使用：
- ✅ `kiosk_visitor_sign_in_controller.dart` - Email 验证

**建议迁移：**
其他可能需要验证的地方也应该使用 ValidationHelper：
- Admin dashboard 表单
- 其他访客信息输入表单
- 用户设置页面
- 任何需要输入验证的地方

---

**创建日期：** 2026-02-11
**版本：** v1.0.0
**状态：** ✅ 已完成并可使用
