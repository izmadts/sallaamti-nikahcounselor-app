import '../../guide/domain/guide_content.dart';

// Trainee-access addendum (15/16 Nov 2026) — the full "working a client A to
// Z" training material the owner wrote out, kept here (not server-fetched)
// for the same reason the existing /guide screen's content is local Dart:
// it rarely changes and the app already has a proven bilingual-markup
// renderer for exactly this shape (GuideSectionCard). This is deliberately
// a SEPARATE screen from /guide — that one is "how to use this app's
// screens" for an already-working counselor; this one is "how the whole
// client-to-proposal process works," read before the in-app assessment.
class TrainingGuideContent {
  static List<GuideSection> forLocale(String languageCode) => languageCode == 'ur' ? _ur : _en;

  static const _en = <GuideSection>[
    GuideSection(title: '1. Lead Creation', paragraphs: [
      'A Lead is anyone who wants our matchmaking service or has contacted us — through Facebook, Instagram, WhatsApp, the website, a phone call, or a referral from someone else.',
      'A lead can be created two ways:',
      '• **Admin creates it** — from any source, and can leave it Unassigned for now.',
      '• **You create it yourself** — if a client contacts you directly, you create their lead from your own app.',
      'Important: a lead you create yourself always stays yours. No other counselor can take it, and admin cannot move it to anyone else either.',
    ]),
    GuideSection(title: '2. Lead Assignment', paragraphs: [
      'Say Sallaamti has 20 new leads from one city, not yet assigned to anyone. Admin can distribute these by city to different counselors.',
      'This isn\'t open to every counselor — only active counselors whose stage is Training, Assessed, Probation, or Certified are eligible for new leads.',
      'When admin assigns a batch, every counselor involved gets an app notification.',
    ]),
    GuideSection(title: '3. Contact & Follow-up (Status)', paragraphs: [
      'Once you have a lead, the real work starts — contact the client, understand their need, guide them.',
      '• **New** — not worked on yet.',
      '• **Contacted** — you\'ve reached them and started the conversation.',
      '• **Interested** — they want to move forward.',
      '• **Hot** — very serious, wants the service urgently.',
      'Set a next follow-up date — if the client says "I\'ll talk again on Friday," set Friday as the follow-up date.',
      'Important: if a lead\'s status doesn\'t change for 5 days, it goes back to the Unassigned pool — so nothing sits untouched. A lead you created yourself is never swept this way.',
    ]),
    GuideSection(title: '4. Registration', paragraphs: [
      'Once a client is ready, the next step is registering them. You can use the Walk-in Wizard in your app to create their account on their behalf.',
      'Or the client can register themselves on their own phone. If their phone number matches an existing lead, the system links that profile to the lead automatically and the lead\'s status becomes Registered.',
    ]),
    GuideSection(title: '5. Verification Fee Payment', paragraphs: [
      'After registration, the next step is the verification fee. The client can pay it themselves, or you can submit payment on their behalf.',
      'Important: submitting payment does NOT verify the profile automatically. Admin must confirm the payment first.',
      'Once admin confirms: the profile becomes Verified, the payment is Confirmed, the lead becomes Paid/Verified, and the **Trusted** badge appears on the profile — so others can see this is a serious, verified profile.',
    ]),
    GuideSection(title: '6. Requirements', paragraphs: [
      'Ask your client what kind of rishta they\'re looking for — age range, city, sect, education, marital status, income, etc. — and record it in the Requirements tab.',
      'This helps Browse filter candidates to match, and helps the system calculate a Match Score for you.',
      'Filling this in isn\'t mandatory, but it genuinely helps give the client faster, better results.',
    ]),
    GuideSection(title: '7. Consent', paragraphs: [
      'Before sending any proposals to a client, you need their consent to participate in matchmaking.',
      'Two ways to get it: record it yourself after asking on a call/in person, or send a Consent Request through the app for the client to confirm themselves.',
      'Important: a Proposal Batch cannot be sent without recorded consent.',
    ]),
    GuideSection(title: '8. Browse & Shortlist', paragraphs: [
      'Once your client is registered, verified, has Requirements saved, and has given consent — it\'s time to find matches using Browse.',
      'Important rule: you can only Browse candidates of the opposite gender to your client. This cannot be changed or bypassed.',
      'Add good matches to the Shortlist — this is only your own working list; nothing has been sent to the client yet. Each candidate shows its verification status: **Trusted**, **Pending**, or **Incomplete** — use this to judge who to send forward.',
    ]),
    GuideSection(title: '9. Proposal Batch', paragraphs: [
      'Remember: adding someone to the Shortlist and actually sending a proposal to the client are two different things.',
      'Build a Proposal Batch from Browse or Shortlist candidates — up to 5 candidates per batch.',
      'The system checks your client\'s package proposal limit before you can Send. Once sent, the client gets a push notification and the proposals have genuinely reached them.',
    ]),
    GuideSection(title: '10. Client Response', paragraphs: [
      'The client sees each candidate\'s profile in their own app and responds: **Interested**, **Not Interested**, or **Maybe**.',
      'The moment a client marks someone Interested, the system automatically creates a normal interest — it then moves forward exactly like any client browsing and liking someone themselves.',
    ]),
    GuideSection(title: '11. Mutual Match', paragraphs: [
      'A client being Interested doesn\'t mean the rishta is settled — the other side\'s real consent is needed too. They see the same interest in their own app and accept or decline it themselves.',
      'You can help by following up with the other side — but to actually contact them, you must send admin a Request Contact, which admin approves.',
      'Once both sides accept, the system creates a Mutual Match and starts the contact-exchange process.',
      'Important: you can never force an acceptance on anyone\'s behalf, and you can never create a Mutual Match yourself — that\'s the normal interest system\'s job alone.',
    ]),
    GuideSection(title: '12. Audit Trail', paragraphs: [
      'Every meaningful action on a client is recorded automatically — when the lead was created, who it was assigned to, when contacted, when registered, when verified, requirements saved, consent recorded, who was shortlisted, when proposals were sent, how the client responded, and when a Mutual Match formed.',
      'All of this lives in one place — the client\'s Timeline — so both you and admin can always see exactly what\'s been done and what\'s next.',
    ]),
    GuideSection(title: '13. Commission', paragraphs: [
      'Your commission is calculated automatically from real milestones — like a Verified Profile or a confirmed package — never something you type in yourself.',
      'Do every client\'s work properly and completely, through every stage, so your commission is recorded correctly.',
    ]),
    GuideSection(title: 'A Complete Example — Sarah\'s Journey', paragraphs: [
      'Sarah wants to find a rishta for herself. Here is her entire journey through the system, start to finish:',
      '• **Lead Creation** — Sarah reaches Sallaamti through Facebook, or contacts a counselor directly. Her lead is created.',
      '• **Assignment** — if she came in through Sallaamti directly, admin assigns her lead to an eligible counselor.',
      '• **Follow-up** — the counselor talks to Sarah, learns what she\'s looking for, and sets a follow-up date if needed.',
      '• **Registration** — Sarah\'s account gets created on Sallaamti and linked to her lead.',
      '• **Verification** — Sarah (or her counselor) submits the verification fee; once admin confirms it, her profile shows the Trusted badge.',
      '• **Requirements** — the counselor records what Sarah is looking for: age, city, education, and so on.',
      '• **Consent** — Sarah agrees to receive proposals.',
      '• **Browse / Shortlist** — the counselor looks through male candidates and shortlists up to 5 good matches.',
      '• **Proposal Batch** — the counselor sends the shortlisted candidates to Sarah as a batch.',
      '• **Client Response** — Sarah marks the ones she likes as Interested.',
      '• **Mutual Match** — the candidate she liked also accepts her from their side — now both sides have a Mutual Match and the contact-exchange process begins.',
      'That\'s the complete journey of one client in the Sallaamti app, from the very first contact to a Mutual Match.',
    ]),
    GuideSection(title: 'Final Reminders for Every Nikah Counselor', paragraphs: [
      '• Give every lead real attention and follow up on time.',
      '• Never leave a lead 5 days without a status update.',
      '• A lead you created yourself always stays yours.',
      '• Record the client\'s requirements accurately.',
      '• Know the difference between "Verified" and "Trusted."',
      '• Never send a Proposal Batch without the client\'s consent.',
      '• Only Browse the opposite gender.',
      '• A batch is capped at 5 candidates.',
      '• Shortlisting someone is not the same as sending them a proposal.',
      '• A candidate being Interested is not the same as a Mutual Match — real acceptance is needed from both sides.',
      'Our goal isn\'t just finding rishtas — it\'s guiding every client responsibly, honestly, and attentively toward a better future for two families, insha\'Allah.',
    ]),
  ];

  static const _ur = <GuideSection>[
    GuideSection(title: '1۔ لیڈ بنانا', paragraphs: [
      'لیڈ کا مطلب ہے ایسا شخص جو ہماری سروس حاصل کرنا چاہتا ہے یا جس نے ہم سے رابطہ کیا ہے — فیس بک، انسٹاگرام، واٹس ایپ، ویب سائٹ، فون کال، یا کسی کے ریفر کرنے سے۔',
      'لیڈ دو طریقوں سے بن سکتی ہے:',
      '• **ایڈمن بنائے** — کسی بھی ذریعے سے، اور فی الحال Unassigned رکھ سکتا ہے۔',
      '• **آپ خود بنائیں** — اگر کوئی کلائنٹ براہ راست آپ سے رابطہ کرے تو آپ خود اپنی ایپ سے اس کی لیڈ بنا سکتے ہیں۔',
      'یاد رکھیں: جو لیڈ آپ خود بناتے ہیں وہ ہمیشہ آپ کی ہی رہتی ہے۔ نہ کوئی دوسرا کاؤنسلر لے سکتا ہے، نہ ایڈمن کسی اور کو منتقل کر سکتا ہے۔',
    ]),
    GuideSection(title: '2۔ لیڈ کی تقسیم', paragraphs: [
      'فرض کریں سلامتی کے پاس ایک شہر سے 20 نئی لیڈز ہیں جو ابھی کسی کو تفویض نہیں ہوئیں۔ ایڈمن انہیں شہر کے حساب سے مختلف کاؤنسلرز میں تقسیم کر سکتا ہے۔',
      'یہ سہولت ہر کاؤنسلر کے لیے نہیں — صرف وہ ایکٹو کاؤنسلرز جن کا اسٹیج Training، Assessed، Probation یا Certified ہو، نئی لیڈز کے اہل ہیں۔',
      'جیسے ہی ایڈمن بیچ تقسیم کرتا ہے، متعلقہ کاؤنسلرز کو ایپ نوٹیفکیشن ملتا ہے۔',
    ]),
    GuideSection(title: '3۔ رابطہ اور فالو اپ (اسٹیٹس)', paragraphs: [
      'لیڈ ملنے کے بعد اصل کام شروع ہوتا ہے — کلائنٹ سے رابطہ کریں، ان کی ضرورت سمجھیں، رہنمائی کریں۔',
      '• **New** — ابھی کام شروع نہیں ہوا۔',
      '• **Contacted** — رابطہ ہو چکا، بات چیت شروع۔',
      '• **Interested** — آگے بڑھنا چاہتے ہیں۔',
      '• **Hot** — بہت سنجیدہ، فوری سروس چاہتے ہیں۔',
      'اگلی فالو اپ تاریخ مقرر کریں — اگر کلائنٹ کہے "جمعہ کو بات کروں گا" تو جمعہ مقرر کر دیں۔',
      'یاد رکھیں: اگر 5 دن تک اسٹیٹس تبدیل نہ ہو تو لیڈ واپس Unassigned pool میں چلی جاتی ہے — تاکہ کوئی لیڈ بغیر توجہ کے نہ رہے۔ آپ کی خود بنائی لیڈ اس اصول سے مستثنیٰ ہے۔',
    ]),
    GuideSection(title: '4۔ رجسٹریشن', paragraphs: [
      'کلائنٹ تیار ہو تو اگلا مرحلہ رجسٹریشن ہے۔ آپ اپنی ایپ کے Walk-in Wizard سے ان کی طرف سے اکاؤنٹ بنا سکتے ہیں۔',
      'یا کلائنٹ خود اپنے فون سے رجسٹر کر سکتا ہے۔ اگر فون نمبر پہلے سے موجود لیڈ سے میچ کرے تو سسٹم خودکار طور پر پروفائل لیڈ سے لنک کر دیتا ہے اور لیڈ Registered ہو جاتی ہے۔',
    ]),
    GuideSection(title: '5۔ ویریفکیشن فیس کی ادائیگی', paragraphs: [
      'رجسٹریشن کے بعد ویریفکیشن فیس کا مرحلہ ہے۔ کلائنٹ خود ادا کر سکتا ہے یا آپ ان کی طرف سے جمع کروا سکتے ہیں۔',
      'یاد رکھیں: فیس جمع کروانے سے پروفائل خودکار ویریفائیڈ نہیں ہوتا۔ پہلے ایڈمن ادائیگی کی تصدیق کرے گا۔',
      'تصدیق کے بعد: پروفائل Verified ہو جاتا ہے، ادائیگی Confirmed ہو جاتی ہے، لیڈ Paid/Verified بن جاتی ہے، اور پروفائل پر **Trusted** بیج ظاہر ہوتا ہے۔',
    ]),
    GuideSection(title: '6۔ Requirements', paragraphs: [
      'کلائنٹ سے پوچھیں وہ کیسا رشتہ چاہتے ہیں — عمر، شہر، فرقہ، تعلیم، ازدواجی حیثیت، آمدنی وغیرہ — اور Requirements ٹیب میں درج کریں۔',
      'یہ Browse کے نتائج فلٹر کرنے اور Match Score نکالنے میں مدد دیتا ہے۔',
      'بھرنا لازمی نہیں، لیکن بہتر اور جلد نتائج کے لیے بہت مفید ہے۔',
    ]),
    GuideSection(title: '7۔ رضامندی (Consent)', paragraphs: [
      'پروپوزل بھیجنے سے پہلے کلائنٹ کی میچ میکنگ میں شرکت کی رضامندی ضروری ہے۔',
      'دو طریقے: خود کال/ملاقات میں پوچھ کر ریکارڈ کریں، یا ایپ سے Consent Request بھیجیں تاکہ کلائنٹ خود کنفرم کرے۔',
      'یاد رکھیں: رضامندی کے بغیر Proposal Batch نہیں بھیجا جا سکتا۔',
    ]),
    GuideSection(title: '8۔ Browse اور Shortlist', paragraphs: [
      'کلائنٹ رجسٹرڈ، ویریفائیڈ ہو، Requirements بھری ہوں اور رضامندی مل چکی ہو تو Browse سے رشتے تلاش کرنے کا وقت ہے۔',
      'اہم اصول: آپ صرف اپنے کلائنٹ کی مخالف جنس کے امیدوار براؤز کر سکتے ہیں۔ یہ تبدیل یا بائی پاس نہیں ہو سکتا۔',
      'اچھے امیدواروں کو Shortlist میں شامل کریں — یہ صرف آپ کی اپنی ورکنگ لسٹ ہے، ابھی کچھ کلائنٹ کو نہیں بھیجا گیا۔ ہر امیدوار پر Trusted، Pending یا Incomplete کا اسٹیٹس نظر آتا ہے۔',
    ]),
    GuideSection(title: '9۔ Proposal Batch', paragraphs: [
      'یاد رکھیں: Shortlist میں شامل کرنا اور کلائنٹ کو پروپوزل بھیجنا دو الگ چیزیں ہیں۔',
      'Browse یا Shortlist سے Proposal Batch بنائیں — ایک بیچ میں زیادہ سے زیادہ 5 امیدوار۔',
      'بھیجنے سے پہلے سسٹم کلائنٹ کے پیکیج کی پروپوزل لمٹ چیک کرتا ہے۔ بھیجنے کے بعد کلائنٹ کو نوٹیفکیشن ملتا ہے اور پروپوزل واقعی پہنچ جاتے ہیں۔',
    ]),
    GuideSection(title: '10۔ کلائنٹ کا جواب', paragraphs: [
      'کلائنٹ اپنی ایپ میں ہر امیدوار کا پروفائل دیکھ کر جواب دیتا ہے: **Interested**، **Not Interested**، یا **Maybe**۔',
      'جیسے ہی کلائنٹ کسی کو Interested کہتا ہے، سسٹم خودکار ایک عام انٹرسٹ بنا دیتا ہے — پھر یہ بالکل اسی طرح آگے بڑھتا ہے جیسے کوئی خود براؤز کرکے کسی کو پسند کرے۔',
    ]),
    GuideSection(title: '11۔ میوچل میچ', paragraphs: [
      'کسی کلائنٹ کا Interested ہونا رشتہ طے ہونے کے برابر نہیں — دوسری طرف کی اصل رضامندی بھی ضروری ہے۔ وہ بھی اپنی ایپ میں یہی انٹرسٹ دیکھ کر خود قبول یا مسترد کریں گے۔',
      'آپ دوسری طرف سے فالو اپ کرکے مدد کر سکتے ہیں — لیکن براہ راست رابطے کے لیے ایڈمن کو Request Contact بھیجنا ہوگا، جسے ایڈمن منظور کرتا ہے۔',
      'دونوں طرف قبولیت ملنے پر سسٹم Mutual Match بنا دیتا ہے اور رابطے کے تبادلے کا عمل شروع ہوتا ہے۔',
      'یاد رکھیں: آپ کبھی کسی کی طرف سے زبردستی قبولیت نہیں دے سکتے، اور نہ خود Mutual Match بنا سکتے ہیں — یہ صرف عام انٹرسٹ سسٹم کا کام ہے۔',
    ]),
    GuideSection(title: '12۔ Audit Trail', paragraphs: [
      'کلائنٹ پر ہر اہم کام خودکار ریکارڈ ہوتا ہے — لیڈ کب بنی، کسے دی گئی، کب رابطہ ہوا، کب رجسٹرڈ ہوا، کب ویریفائی ہوا، Requirements کب بھریں، رضامندی کب ریکارڈ ہوئی، شارٹ لسٹ کون بنا، پروپوزل کب بھیجے، کلائنٹ نے کیا جواب دیا، اور Mutual Match کب بنا۔',
      'یہ سب کچھ ایک ہی جگہ — کلائنٹ کی Timeline میں — موجود ہے، تاکہ آپ اور ایڈمن ہمیشہ دیکھ سکیں کہ اب تک کیا ہوا اور آگے کیا کرنا ہے۔',
    ]),
    GuideSection(title: '13۔ کمیشن', paragraphs: [
      'آپ کا کمیشن اصل سنگ میل سے خودکار حساب ہوتا ہے — جیسے Verified Profile یا کنفرم شدہ پیکیج — کبھی خود لکھ کر درج نہیں کرتے۔',
      'ہر کلائنٹ کا کام مکمل اور صحیح طریقے سے، ہر مرحلے سے گزار کر کریں، تاکہ آپ کا کمیشن درست ریکارڈ ہو۔',
    ]),
    GuideSection(title: 'ایک مکمل مثال — سارہ کا سفر', paragraphs: [
      'سارہ اپنے لیے رشتہ تلاش کرنا چاہتی ہیں۔ یہ ہے ان کا مکمل سفر، شروع سے آخر تک:',
      '• **Lead Creation** — سارہ فیس بک کے ذریعے سلامتی تک پہنچتی ہیں، یا براہ راست کسی کاؤنسلر سے رابطہ کرتی ہیں۔ ان کی لیڈ بن جاتی ہے۔',
      '• **Assignment** — اگر سلامتی سے براہ راست آئی ہیں تو ایڈمن یہ لیڈ کسی اہل کاؤنسلر کو دیتا ہے۔',
      '• **Follow-up** — کاؤنسلر سارہ سے بات کرتا ہے، ان کی ضرورت جانتا ہے، ضرورت پڑے تو فالو اپ تاریخ مقرر کرتا ہے۔',
      '• **Registration** — سارہ کا اکاؤنٹ سلامتی پر بن جاتا ہے اور ان کی لیڈ سے لنک ہو جاتا ہے۔',
      '• **Verification** — سارہ (یا کاؤنسلر) ویریفکیشن فیس جمع کرواتے ہیں؛ ایڈمن تصدیق کرنے پر پروفائل پر Trusted بیج آ جاتا ہے۔',
      '• **Requirements** — کاؤنسلر سارہ کی پسند درج کرتا ہے: عمر، شہر، تعلیم وغیرہ۔',
      '• **Consent** — سارہ پروپوزل وصول کرنے پر راضی ہوتی ہیں۔',
      '• **Browse / Shortlist** — کاؤنسلر مرد امیدواروں کو دیکھ کر 5 تک اچھے امیدوار شارٹ لسٹ کرتا ہے۔',
      '• **Proposal Batch** — کاؤنسلر شارٹ لسٹ شدہ امیدوار سارہ کو بیچ کی صورت بھیجتا ہے۔',
      '• **Client Response** — سارہ جسے پسند کریں اسے Interested کہتی ہیں۔',
      '• **Mutual Match** — پسند کیا گیا امیدوار بھی اپنی طرف سے قبول کر لیتا ہے — اب دونوں طرف Mutual Match بن جاتا ہے اور رابطے کا تبادلہ شروع ہوتا ہے۔',
      'یہ ہے ایک کلائنٹ کا سلامتی ایپ میں پہلے رابطے سے لے کر Mutual Match تک کا مکمل سفر۔',
    ]),
    GuideSection(title: 'ہر نکاح کاؤنسلر کے لیے آخری یاد دہانی', paragraphs: [
      '• ہر لیڈ کو وقت دیں اور بروقت فالو اپ کریں۔',
      '• کسی لیڈ کو 5 دن بغیر اسٹیٹس اپڈیٹ کے نہ چھوڑیں۔',
      '• جو لیڈ آپ خود بنائیں وہ ہمیشہ آپ کی رہتی ہے۔',
      '• کلائنٹ کی Requirements درست درج کریں۔',
      '• "Verified" اور "Trusted" کا فرق سمجھیں۔',
      '• کلائنٹ کی رضامندی کے بغیر Proposal Batch نہ بھیجیں۔',
      '• صرف مخالف جنس Browse کریں۔',
      '• بیچ میں زیادہ سے زیادہ 5 امیدوار۔',
      '• شارٹ لسٹ کرنا پروپوزل بھیجنے کے برابر نہیں۔',
      '• کسی کا Interested ہونا Mutual Match کے برابر نہیں — دونوں طرف سے اصل قبولیت ضروری ہے۔',
      'ہمارا مقصد صرف رشتے تلاش کرنا نہیں — ہر کلائنٹ کی ذمہ داری، ایمانداری اور توجہ کے ساتھ رہنمائی کرنا ہے، تاکہ دو خاندان ان شاءاللہ ایک بہتر مستقبل کی طرف بڑھیں۔',
    ]),
  ];
}
