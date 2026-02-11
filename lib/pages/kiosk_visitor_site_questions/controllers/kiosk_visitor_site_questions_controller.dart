import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:visitor_practise/core/models/badge_generator.dart';
import 'package:visitor_practise/core/models/site_item.dart';
import 'package:visitor_practise/core/models/site_question.dart';
import 'package:visitor_practise/core/models/visitor_data.dart';
import 'package:visitor_practise/services/api_service.dart';
import 'package:visitor_practise/services/model_service/badge_generator_service.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';
import 'package:visitor_practise/services/notification_service.dart';
import 'package:visitor_practise/shared_widgets/parent_widgets/ui_message.dart';

class KioskVisitorSiteQuestionsController extends ChangeNotifier {
  //Background and Logo------------------------------------
  Uint8List? topLogo;
  Uint8List? bottomLogo;
  Uint8List? background;

  // Visitor data from previous page
  VisitorData? _visitorData;
  VisitorData? get visitorData => _visitorData;

  // Questions and answers
  List<SiteQuestion> _questions = [];
  List<SiteQuestion> get questions => _questions;

  final Map<String, bool> _answers = {};
  Map<String, bool> get answers => _answers;

  // Badge data
  Uint8List? _badgeImageBytes;
  Uint8List? get badgeImageBytes => _badgeImageBytes;

  // Current site
  SiteItem? _currentSite;
  SiteItem? get currentSite => _currentSite;

  // Get site title for display
  String getSiteTitle() {
    if (_currentSite == null) return 'Site Safety Questions';
    return _currentSite!.displayName;
  }

  // status
  bool _isCheckingInitial = true;
  bool get isCheckingInitial => _isCheckingInitial;
  bool _isLoadingQuestions = false;
  bool get isLoadingQuestions => _isLoadingQuestions;
  bool _submitting = false;
  bool get submitting => _submitting;
  bool _generatingBadge = false;
  bool get generatingBadge => _generatingBadge;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Initialize with visitor data from previous page
  Future<void> initialise(VisitorData visitorData) async {
    try {
      _visitorData = visitorData;

      // Load logos and background
      topLogo = await SecureStorageService.getClientTopLogoBytes().timeout(const Duration(seconds: 5));
      bottomLogo = await SecureStorageService.getClientBottomLogoBytes().timeout(const Duration(seconds: 5));
      background = await SecureStorageService.getClientBackgroundBytes().timeout(const Duration(seconds: 5));

      // Load current site
      final savedSelectedSite = await SecureStorageService.getSelectedSite().timeout(const Duration(seconds: 5));
      if (savedSelectedSite != null && savedSelectedSite.isNotEmpty) {
        final currentSiteMap = jsonDecode(savedSelectedSite) as Map<String, dynamic>;
        _currentSite = SiteItem.fromJson(currentSiteMap);
      }

      // Load questions
      await loadQuestions();

      _isCheckingInitial = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during initialization: $e');
      _errorMessage = 'Failed to initialize: $e';
      _isCheckingInitial = false;
      notifyListeners();
    }
  }

  /// Load site-specific questions from API
  Future<void> loadQuestions() async {
    try {
      _isLoadingQuestions = true;
      _errorMessage = null;
      notifyListeners();

      final token = await SecureStorageService.getAuthToken().timeout(const Duration(seconds: 5));
      if (token == null || token.isEmpty) {
        // Use default questions if no token
        _questions = await SiteQuestion.getDefaultQuestions();
        _initializeAnswers();
        _isLoadingQuestions = false;
        notifyListeners();
        return;
      }

      // Fetch site-specific questions from API
      final response = await ApiService.fetchSiteQuestions(
        token,
        _visitorData?.siteId ?? '',
      );

      if (response.isNotEmpty) {
        _questions = response
            .map((json) => SiteQuestion.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // Use default questions if API returns empty
        _questions = await SiteQuestion.getDefaultQuestions();
      }

      _initializeAnswers();
      _isLoadingQuestions = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading questions: $e');
      // Use default questions on error
      _questions = await SiteQuestion.getDefaultQuestions();
      _initializeAnswers();
      _errorMessage = 'Using default questions';
      _isLoadingQuestions = false;
      notifyListeners();
    }
  }

  /// Initialize answers map with null values
  void _initializeAnswers() {
    _answers.clear();
    for (final question in _questions) {
      _answers[question.id] = false; // Default to false (No)
    }
  }

  /// Set answer for a specific question
  void setAnswer(String questionId, bool answer) {
    _answers[questionId] = answer;
    notifyListeners();
  }

  /// Check if all questions have been answered
  bool get allQuestionsAnswered {
    if (_questions.isEmpty) return false;
    return _answers.length == _questions.length &&
        _answers.values.every((answer) => answer != null);
  }

  /// Check if all answers are Yes (true)
  bool get allAnswersYes {
    if (!allQuestionsAnswered) return false;
    return _answers.values.every((answer) => answer == true);
  }

  /// Get answer for a specific question
  bool? getAnswer(String questionId) {
    return _answers[questionId];
  }

  /// Submit sign-in, generate badge and proceed to final badge page
  Future<bool> proceedToBadge(BuildContext context) async {
    try {
      // Validate all answers are Yes
      if (!allAnswersYes) {
        if (context.mounted) {
          context.showError('All questions must be answered "Yes" to proceed');
        }
        return false;
      }

      _submitting = true;
      _errorMessage = null;
      notifyListeners();

      // Get auth token
      final token = await SecureStorageService.getAuthToken().timeout(const Duration(seconds: 5));
      if (token == null || token.isEmpty) {
        if (context.mounted) context.showError('Authentication token not found');
        _submitting = false;
        notifyListeners();
        return false;
      }

      // Build agree data based on question type
      final agreeData = _buildAgreeData();

      // Generate unique visitor ID
      final uniqueId = 'VIS${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';

      // STEP 1: Submit to API (including questions)
      final response = await ApiService.submitSignInLedger(
        token: token,
        siteId: _visitorData!.siteId,
        name: _visitorData!.fullName,
        email: _visitorData!.email,
        questions: agreeData,
        uniqueId: uniqueId,
        organisation: _visitorData!.company,
        phone: _visitorData!.phone,
        address: _visitorData!.address,
        workType: _visitorData!.workType,
        supervisor: _visitorData!.contactDetailName,
        signInTime: _visitorData!.signInTime,
        visitorPhotoBytes: _visitorData!.visitorPhotoBytes,
        visitorPhotoFilename: _visitorData!.visitorPhotoBytes != null ? 'visitor_photo.jpg' : null,
      );

      // Check for errors
      if (response.containsKey('error')) {
        final errorMsg = response['error'].toString();
        if (context.mounted) context.showError(errorMsg);
        _errorMessage = errorMsg;
        _submitting = false;
        notifyListeners();
        return false;
      }

      // Get server-assigned visitor ID
      final serverVisitorId = response['visitor_id']?.toString() ??
                             response['unique_id']?.toString() ??
                             uniqueId;

      // Update visitor data with server ID
      _visitorData = _visitorData!.copyWith(
        visitorId: serverVisitorId,
        siteQuestionAnswers: Map<String, bool>.from(_answers),
      );

      // STEP 2: Send notifications to Person Visiting
      if (_visitorData!.sendSms || _visitorData!.sendEmail) {
        try {
          await NotificationService.sendSignInNotifications(
            personVisitingId: _visitorData!.contactDetailId,
            personVisitingName: _visitorData!.contactDetailName,
            personVisitingEmail: _visitorData!.contactDetailEmail,
            personVisitingPhone: _visitorData!.contactDetailPhone,
            visitorName: _visitorData!.fullName,
            visitorCompany: _visitorData!.company,
            visitorEmail: _visitorData!.email,
            visitorPhone: _visitorData!.phone,
            siteName: _currentSite?.title ?? 'Site',
            signInTime: _visitorData!.signInTime,
            authToken: token,
            sendSms: _visitorData!.sendSms,
            sendEmail: _visitorData!.sendEmail,
          );
        } catch (e) {
          debugPrint('Error sending notifications: $e');
          // Continue even if notifications fail - don't block the sign-in process
        }
      }

      // STEP 3: Generate badge
      _generatingBadge = true;
      notifyListeners();

      final topLogoBytes = await SecureStorageService.getClientTopLogoBytes().timeout(const Duration(seconds: 5));

      final badgeData = BadgeGenerator(
        visitorId: serverVisitorId,
        fullName: _visitorData!.fullName,
        email: _visitorData!.email,
        phone: _visitorData!.phone,
        workType: _visitorData!.workType,
        company: _visitorData!.company,
        address: _visitorData!.address,
        supervisor: _visitorData!.contactDetailName,
        signInTime: _visitorData!.signInTime,
        siteName: _currentSite?.title ?? 'Site',
        clientLogoBytes: topLogoBytes,
        visitorPhotoBytes: _visitorData!.visitorPhotoBytes,
      );

      _badgeImageBytes = await BadgeGeneratorService.generateBadgeBytes(badgeData);

      _generatingBadge = false;
      _submitting = false;
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error submitting sign-in: $e');
      _errorMessage = 'Failed to submit: $e';
      _generatingBadge = false;
      _submitting = false;
      notifyListeners();

      if (context.mounted) {
        context.showError('Failed to submit: $e');
      }

      return false;
    }
  }

  /// Build agree data based on question type (default vs customized)
  Map<String, dynamic> _buildAgreeData() {
    // Check if using customized questions (have form_id)
    final hasCustomQuestions = _questions.isNotEmpty &&
                               _questions.first.formId != null &&
                               _questions.first.formId!.isNotEmpty;

    if (hasCustomQuestions) {
      // Customized format
      return {
        'sign_form_id': int.tryParse(_questions.first.formId!) ?? 0,
        'project_question': _questions.map((q) => _answers[q.id] == true ? 'Yes' : 'No').toList(),
        'questions': _questions.map((q) => {
          'name': q.id,
          'question': q.text,
        }).toList(),
      };
    } else {
      // Default format
      final agreeMap = <String, dynamic>{};
      for (var entry in _answers.entries) {
        agreeMap[entry.key] = entry.value;
      }
      return agreeMap;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}