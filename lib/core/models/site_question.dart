/// Site Question Model
/// Represents a question that must be answered during visitor sign-in
class SiteQuestion {
  final String id;
  final String text;
  final List<String> options;
  final String? formId; // sign_form_id for customized questions

  SiteQuestion({
    required this.id,
    required this.text,
    required this.options,
    this.formId,
  });

  /// Default site safety questions (used when site has no custom questions)
  /// companyName should be fetched from API: fetchVisitorClient
  static List<SiteQuestion> getDefaultQuestions(String companyName) {
    final name = companyName.trim().isEmpty ? 'the company' : companyName;
    return [
      SiteQuestion(
        id: '1',
        text: 'I have been advised of the required minimum PPE for this site.',
        options: ['Yes', 'No'],
      ),
      SiteQuestion(
        id: '2',
        text: 'Observe all safety signage, read and follow site rules & instructions of the Site Supervisor.',
        options: ['Yes', 'No'],
      ),
      SiteQuestion(
        id: '3',
        text: 'Not smoke on site except in Designated Areas.',
        options: ['Yes', 'No'],
      ),
      SiteQuestion(
        id: '4',
        text: 'Be escorted by an authorised $name representative at all times.',
        options: ['Yes', 'No'],
      ),
      SiteQuestion(
        id: '5',
        text: 'In the event of fire or emergency evacuation, follow the instructions of $name representative.',
        options: ['Yes', 'No'],
      ),
      SiteQuestion(
        id: '6',
        text: 'Report any incidents / accident immediately.',
        options: ['Yes', 'No'],
      ),
    ];
  }

  factory SiteQuestion.fromJson(Map<String, dynamic> json) {
    final List<String> parsedOptions;
    final dynamic rawOptions = json['options'];
    if (rawOptions is List) {
      parsedOptions = rawOptions
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    } else {
      parsedOptions = [];
    }
    if (parsedOptions.isEmpty) {
      parsedOptions.addAll(['Yes', 'No']);
    }

    return SiteQuestion(
      id: json['id']?.toString() ??
          json['question_id']?.toString() ??
          json['name']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      text: json['question']?.toString() ??
          json['text']?.toString() ??
          'Untitled Question',
      options: parsedOptions,
      formId: json['form_id']?.toString() ??
              json['sign_form_id']?.toString(),
    );
  }
}

/*
Logic: if it is default question - return 1. default quest, otherwise, it is the customized question - return 2. customized sign in question
//-----------------------------
default questions: 
I have been advised of the required minimum PPE for this site. 

Observe all safety signage, read and follow site rules & instructions of the Site Supervisor. 

Not smoke on site except in Designated Areas. 

Be escorted by an authorised {$clientName}  representative at all times. 

In the event of fire or emergency evacuation, follow the instructions of {$clientName} representative. 

Report any incidents / accident immediately.
//----------------------------------

1. default quest:
{
  "name": "Travis McLean ",
  "email": "travis.mclean@newheightsplumbing.com.au",
  "organisation": "New Heights Plumbing ",
  "phone": "0439028167",
  "inductions": [],
  "agree": {
    "1": true,
    "2": true,
    "3": true,
    "4": true,
    "5": true,
    "6": true
  },
  "unique_id": "VIS69363c49e713a"
}

2. customized sign in question
{
  "name": "Jake G Harris",
  "email": "jakeh@harleydykstra.com.au",
  "organisation": "Harley Dykstra",
  "phone": "0428837763",
  "inductions": [],
  "agree": {
    "sign_form_id": 71,
    "project_question": [
      "Yes",
      "Yes",
      "Yes",
      "Yes",
      "Yes",
      "Yes",
      "Yes"
    ],
    "questions": [
      {
        "name": "1",
        "question": "I have been informed of and understand the hazards associated with this site, including but not limited to moving plant, uneven ground, noise, dust, and other construction activities"
      },
      {
        "name": "2",
        "question": "I will NOT be performing any tasks/whilst onsite"
      },
      {
        "name": "3",
        "question": "I have received and understand the site safety rules, emergency procedures, and any instructions relevant to my visit"
      },
      {
        "name": "4",
        "question": "I will comply with all reasonable directions given by site management and wear the required personal protective equipment (PPE) at all times"
      },
      {
        "name": "5",
        "question": "I will not enter any restricted areas unless authorised and accompanied by an authorised person"
      },
      {
        "name": "6",
        "question": "I accept responsibility for my own actions while on site and understand that failure to follow site rules may result in removal from the premises"
      },
      {
        "name": "7",
        "question": "I will conduct myself in a manner that does not place myself or others at risk"
      }
    ]
  },
  "unique_id": "VIS693611ca241d7"
}
*/