import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:visitor_practise/core/models/site_item.dart';
import 'package:visitor_practise/core/models/site_question.dart';
import 'package:visitor_practise/core/models/visitor_data.dart';
import 'package:visitor_practise/pages/kiosk_visitor_sign_in/controllers/kiosk_visitor_sign_in_controller.dart';
import 'package:visitor_practise/services/api_service.dart';
import 'package:visitor_practise/services/secure_storage_service.dart';
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

  // Current site
  SiteItem? _currentSite;
  SiteItem? get currentSite => _currentSite;

  // Printer settings from kiosk dashboard
  bool _reqPrint = false;
  bool get reqPrint => _reqPrint;

  bool _isPrinterReady = false;
  bool get isPrinterReady => _isPrinterReady;

  // Field configurations from kiosk dashboard - for badge generation
  bool _reqFullName = true;
  bool get reqFullName => _reqFullName;

  bool _reqEmail = true;
  bool get reqEmail => _reqEmail;

  bool _reqPhone = false;
  bool get reqPhone => _reqPhone;

  bool _reqWorkType = false;
  bool get reqWorkType => _reqWorkType;

  bool _reqCompany = false;
  bool get reqCompany => _reqCompany;

  bool _reqAddress = false;
  bool get reqAddress => _reqAddress;

  bool _reqPersonVisiting = false;
  bool get reqPersonVisiting => _reqPersonVisiting;

  bool _reqSignInTime = false;
  bool get reqSignInTime => _reqSignInTime;

  bool _reqVisitorPhoto = false;
  bool get reqVisitorPhoto => _reqVisitorPhoto;

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

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Initialize with data from KioskVisitorSignInController (reuses loaded data)
  /// Returns true if successful, false if failed
  Future<bool> initialiseWithSignInController(
    VisitorData visitorData,
    KioskVisitorSignInController signInController,
  ) async {
    try {
      _visitorData = visitorData;

      // Reuse already-loaded assets from signInController
      topLogo = signInController.topLogo;
      bottomLogo = signInController.bottomLogo;
      background = signInController.background;
      _currentSite = signInController.currentSite;

      // Get printer settings from signInController
      _reqPrint = signInController.reqPrint;
      _isPrinterReady = signInController.isPrinterReady;

      // Get field configurations from signInController
      _reqFullName = signInController.reqFullName;
      _reqEmail = signInController.reqEmail;
      _reqPhone = signInController.reqPhone;
      _reqWorkType = signInController.reqWorkType;
      _reqCompany = signInController.reqCompany;
      _reqAddress = signInController.reqAddress;
      _reqPersonVisiting = signInController.reqPersonVisiting;
      _reqSignInTime = signInController.reqSignInTime;
      _reqVisitorPhoto = signInController.reqVisitorPhoto;

      // Load questions - if fails, return false
      final questionsLoaded = await loadQuestions();
      if (!questionsLoaded) {
        _isCheckingInitial = false;
        notifyListeners();
        return false;
      }

      _isCheckingInitial = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error during initialization: $e');
      _errorMessage = 'Failed to initialize: $e';
      _isCheckingInitial = false;
      notifyListeners();
      return false;
    }
  }

  /// Load site-specific questions from API
  /// Always succeeds - uses default questions if API fails
  Future<bool> loadQuestions() async {
    _isLoadingQuestions = true;
    _errorMessage = null;
    notifyListeners();

    // Step 1: Get token
    final token = await SecureStorageService.getAuthToken().timeout(const Duration(seconds: 5));
    if (token == null || token.isEmpty) {
      _questions = SiteQuestion.getDefaultQuestions('the company');
      _initializeAnswers();
      _isLoadingQuestions = false;
      notifyListeners();
      return true;
    }

    // Step 2: Fetch client name from API (for default questions)
    String companyName = 'the company';
    try {
      final clientData = await ApiService.fetchVisitorClient(token).timeout(const Duration(seconds: 5));
      companyName = clientData['trading_name']?.toString().trim() ??
                    clientData['name']?.toString().trim() ??
                    'the company';
      debugPrint('Fetched company name: $companyName');
    } catch (e) {
      debugPrint('Error fetching client: $e');
    }

    // Step 3: Fetch site-specific questions from API
    try {
      final response = await ApiService.fetchSiteQuestions(
        token,
        _visitorData?.siteId ?? '',
      );

      if (response.isNotEmpty) {
        _questions = response
            .map((json) => SiteQuestion.fromJson(json as Map<String, dynamic>))
            .toList();
        debugPrint('Loaded ${_questions.length} questions from API');
      } else {
        // Use default questions if API returns empty
        _questions = SiteQuestion.getDefaultQuestions(companyName);
        debugPrint('Using default questions with company: $companyName');
      }
    } catch (e) {
      debugPrint('Error fetching site questions: $e');
      // Use default questions on error
      _questions = SiteQuestion.getDefaultQuestions(companyName);
      debugPrint('Using default questions (error) with company: $companyName');
    }

    _initializeAnswers();
    _isLoadingQuestions = false;
    notifyListeners();
    return true;
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
    return _answers.length == _questions.length;
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

  /// Build agree data based on question type (default vs customized)
  /// Public method so FinalBadgeController can use it for API submission
  Map<String, dynamic> buildAgreeData() {
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

  /// Validate questions and proceed to final badge page
  /// Badge generation and API submission moved to FinalBadgeController
  bool validateAndProceed(BuildContext context) {
    // Validate all answers are Yes
    if (!allAnswersYes) {
      if (context.mounted) {
        context.showError('All questions must be answered "Yes" to proceed');
      }
      return false;
    }

    // Update visitor data with answers
    _visitorData = _visitorData!.copyWith(
      siteQuestionAnswers: Map<String, bool>.from(_answers),
    );

    return true;
  }

}
