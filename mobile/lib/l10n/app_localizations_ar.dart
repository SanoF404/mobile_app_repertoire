// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'جهات الاتصال';

  @override
  String get search => 'ابحث عن جهة اتصال';

  @override
  String get addContact => 'إضافة جهة اتصال';

  @override
  String get firstName => 'الاسم';

  @override
  String get lastName => 'اللقب';

  @override
  String get phone => 'الهاتف';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get empty => 'لا توجد جهات اتصال. أضف جهة اتصال أولى.';

  @override
  String get noResults => 'لا توجد نتائج.';

  @override
  String get invalidPhone => 'رقم غير صالح';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get confirmDelete => 'هل تريد حذف جهة الاتصال؟';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get close => 'إغلاق';

  @override
  String get language => 'Français';

  @override
  String get duplicatePhone => 'هذا الرقم موجود بالفعل.';
}
