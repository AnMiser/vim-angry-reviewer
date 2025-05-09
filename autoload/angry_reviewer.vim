function! angry_reviewer#AngryReviewer()

python3 << EOF

import vim
import re
from datetime import date

ELEMENTS = {'Al', 'Si', 'Cr', 'Ga', 'Ti', 'GaAs', 'SiC', 'Cu', 'Ge',
    'Li', 'Ne', 'Na', 'Cl', 'Ar', 'Au', 'VO2', 'Sc', 'Fe', 'Nb', 'Ni', 'SiGe',
    'Sr', 'Zr', 'Ag', 'Ta', 'Pt', 'Hg', 'U', 'O2', 'H2O', 'Sn', 'Sb',
    'SiN', 'SiO', 'H', 'N', 'GaN', 'InP', 'InAs', 'GaP', 'AlP', 'He',
    'BAs', 'BN', 'AlN', 'TiNiSn', 'AlGaAs', }

UNITS = {"m.", "m ", "mm", "um", "nm", "km", "cm", "W", "V", "K", "s ",
    "s.", "ps", "us ", "Pa", "min", "h.", "h,", "h ", "Hz", "GHz", "THz", "MHz",
    "g", 'mg', 'ml', 'nV', 'mV', 'mW', 'nW', 'MPa', 'GPa'}

EXCEPTIONS = {'RESULTS', 'DISCUSSION', 'DISCUSSIONS','METHODS', 'JST',
    'INTRODUCTION', 'LIMMS', 'DNA', 'RNA', 'IIS', 'CREST', 'PRESTO', 'PNAS',
    'APL', 'ZT', 'LaTeX', 'MEMS', 'NEMS', 'AIP', 'AM', 'PM', 'AIDS', 'AC', 'DC',
    'CNRS', 'KAKENHI', 'APA', 'GaA', 'ErA', 'AlA', 'BA', 'BibTeX', 'APS', 'InA',
    'LED', 'OLED', 'ACS', 'PhD', 'MIT', 'NASA', 'HIV', 'RAM', 'CPU', 'LCD', 'LED',
    'OLED', 'AFM', 'SEM', 'TEM', 'TDTR', 'COMSOL', 'APPOLO', 'ELMER', 'COVID'}

OVERUSED_INTRO = {
    'However': 'But or Yet',
    'Thus': 'Hence or Therefore',
    'Hence': 'Thus or Therefore',
    'Therefore': 'Thus or Hence',
    'Since': 'Because or As',
    'Yet': 'However or But',
    'In addition': 'Also',
    'Moreover': 'Also',
    'Indeed': 'For example',
    'Furthermore': 'Also or Moreover',
    'First': 'To begin',
    'On the other hand': 'However, Yet, or But',
    }

COMMA_AFTER = [
    'However ',
    'Therefore ',
    'Thus ',
    'Yet ',
    'Hence ',
    'Nevertheless ',
    'But ',
    'In this work ',
    'In this article ',
    'In this paper ',
    'In this case ',
    'In that case ',
    'Moreover ',
    'Consequently ',
    'So ',
    'In conclusion ',
    'In conclusions ',
    'Particularly ',
    'Specifically ',
    'For this reason ',
    'For these reasons ',
    'On the other hand ',
    'On the one hand ',
    'On one hand ',
    'Furthermore ',
    'In the meantime ',
    ]

BRITISH = {
    'vapour': 'vapor',
    'colour': 'color',
    'favourite': 'favorite',
    'flavour': 'flavor',
    'behaviour': 'behavior',
    'neighbour': 'neighbor',
    'honour': 'honor',
    ' metre': ' meter',
    'nanometre': 'nanometer',
    'micrometre': 'micrometer',
    'centimetre': 'centimeter',
    'kilometre': 'kilometer',
    'labour': 'labor',
    'centre': ' center',
    'spectre': 'specter',
    'calibre': 'caliber',
    'theatre': 'theater',
    'litre': 'liter ',
    'tumour': 'tumor',
    'fibre': 'fiber',
    'analogue ': 'analog ',
    'analogues': 'analogs',
    'catalogues ': 'catalog ',
    'catalogues': 'catalogs',
    'dialogue ': 'dialog ',
    'dialogues': 'dialogs',
    'homologue': 'homolog ',
    'analyse': 'analyze',
    'catalyse': 'catalyze',
    'hydrolyse': 'hydrolyze',
    'haemolyse': 'hemolyze',
    'anatomical': 'anatomic ',
    'biological': 'biologic ',
    'morphological': 'morphologic ',
    'serological': 'serologic ',
    'defence': 'defense',
    'offence': 'offense',
    'pretence': 'pretense',
    'fulfil': 'fulfill',
    'enrol ': 'enroll ',
    'enrols': 'enrolls',
    'distil ': 'distill ',
    'distils': 'distills',
    'instalment': 'installment',
    'labelled': 'labeled',
    'labelling': 'labeling',
    'modelled': 'modeled',
    'modelling': 'modeling',
    'modeller': 'modeler',
    'travelled': 'traveled',
    'travelling': 'traveling',
    'traveller': 'traveler',
    'adrenocorticotrophic': 'adrenocorticotropic',
    'gonadotrophin': 'gonadotropin',
    'thyrotrophin': 'thyrotropin',
    'e.g. ': 'e.g.,',
    'i.g. ': 'i.g.,',
    'aluminium': 'aluminum',
    'anti-clockwise': 'counterclockwise',
    'grey': 'gray',
    ' plough': ' plow',
    ' tyre': ' tire',
    'towards': 'toward ',
    ' ageing': ' aging',
    'anaesthetic': 'anesthetic',
    'haemoglobin': 'hemoglobin',
    'leukaemia': 'leukemia',
    'oestrogen': 'estrogen',
    'oesophagus': 'esophagus',
    'oedema': 'edema',
    'diarrhoea': 'diarrhea',
    'dyspnoea': 'dyspnea',
    'manoeuvre': 'maneuver',
    'Mr ': 'Mr.',
    'Dr ': 'Dr.',
    'Mrs ': 'Mrs.',
    'St ': 'St.',
    }

VERY = {
    'very precise': 'precise, exact, unimpeachable, perfect, flawless',
    'very basic': 'rudimentary, primary, fundamental, simple',
    'very capable': 'efficient, proficient, skillful',
    'very clean': 'spotless, immaculate, stainless',
    'very clear': 'transparent, sheer, translucent',
    'very competitive': 'ambitious, driven, cutthroat',
    'very confident': 'self-assured, self-reliant, secure',
    'very consistent': 'constant, unfailing, uniform, same',
    'very conventional': 'conservative, common, predictable, unoriginal',
    'very critical': 'vital, crucial, essential, indispensable, integral',
    'very dangerous': 'perilous, precarious, unsafe',
    'very dark': 'black, inky, ebony, sooty',
    'very deep': 'abysmal, bottomless, vast',
    'very delicate': 'subtle, slight, fragile, frail', 'very different': 'unusual, distinctive, atypical, dissimilar',
    'very difficult': 'complicated, complex, demanding',
    'very easy': 'effortless, uncomplicated, unchallenging, simple',
    'very fast': 'rapid, swift, fleet, blistering',
    'very first': 'first',
    'very few': 'meager, scarce, scant, limited, negligible',
    'very good': 'superb, superior, excellent',
    'very important': 'crucial, vital, essential, paramount, imperative',
    'very impressive': 'extraordinary, remarkable',
    'very interesting': 'fascinating, remarkable, intriguing, compelling',
    'very large': 'huge, giant',
    'very long': 'extended, extensive, interminable, protracted',
    'very new': 'innovative, fresh, original, cutting-edge',
    'very obvious': 'apparent, evident, plain, visible',
    'very reasonable': 'equitable, judicious, sensible, practical, fair',
    'very recent': 'the latest, current, fresh, up-to-date',
    'very rough': 'coarse, jagged, rugged, craggy, gritty, broken',
    'very severe': 'acute, grave, critical, serious, brutal, relentless',
    'very significant': 'key, notable, substantial, noteworthy, momentous, major, vital',
    'very similar': 'alike, akin, analogous, comparable, equivalent',
    'very simple': 'basic, easy, straightforward, effortless, uncomplicated',
    'very small': 'tiny, minuscule, infinitesimal, microscopic, petite',
    'very smooth': 'flat, glassy, polished, level, even, unblemished',
    'very specific': 'precise, exact, explicit, definite, unambiguous',
    'very strange': 'weird, eerie, bizarre, uncanny, peculiar, odd',
    'very strict': 'stern, austere, severe, rigorous, harsh, rigid',
    'very substantial': 'considerable, significant, extensive, ample',
    'very unlikely': 'improbable, implausible, doubtful, dubious',
    'very unusual': 'abnormal, extraordinary, uncommon, unique',
    'very visible': 'conspicuous, exposed, obvious, prominent',
    'very weak': 'feeble, frail, delicate, debilitated, fragile',
    'very wide': 'vast, expansive, sweeping, boundless',
    'very afraid': 'terrified',
    'very often': 'frequently',
    'very old': 'ancient',
    'very open': 'transparent',
    'very perfect': 'flawless',
    'very powerful': 'compelling',
    'very quick': 'rapid',
    'very quiet': 'hushed',
    'very serious': 'grave',
    'very shiny': 'gleaming',
    'very short': 'brief',
    }

BAD_PATTERNS = {

    # Hype 

    'excellent agreement': 'Usually, the agreement is not so excellent. Consider replacing with "good agreement" or better yet, quantify the agreement, e.g. "A agrees with B within 5% uncertainty".',
    'excellent fit': 'Often, the fit is not so excellent. Consider quantifying the fit, e.g. "Line fits the data within 5% of uncertainty".',
    'comprehensive review': 'Consider if the review is really "comprehensive". More often than not it is hype.',
    'outstanding': 'The word "outstanding" might be considered hype. Consider alternatives, e.g. "remarkable".',
    'groundbreaking': 'The word "groundbreaking" might be considered hype. Consider alternatives, e.g. "remarkable".',
    'ground breaking': 'The word "groundbreaking" might be considered hype. Consider alternatives, e.g. "remarkable".',
    'new ': 'If the word "new" refers to the results or methods, editors and reviewers often dislike such claims. Consider explaining novelty in some other way. Some helpful words are "innovative", "original", "alternative", "previously unknown".',
    'novel ': 'If the word "novel" refers to the results or methods, editors and reviewers often dislike such claims. Consider explaining novelty in some other way. Some helpful words are "innovative", "original", "cutting-edge", "alternative", "previously unknown".',
    ' prove ': 'Phrases about "prove" should be considered with caution. Strict proof is possible only in math, whereas science usually operates with evidence. Consider replacing with words like "evidence", "demonstration", "confirmation" etc.',
    ' proved ': 'Phrases about "prove" should be considered with caution. Strict proof is possible only in math, whereas science usually operates with evidence. Consider replacing with words like "evidence", "demonstration", "confirmation" etc.',
    ' proof ': 'Phrases about "proof" should be considered with caution. Strict proof is possible only in math, whereas science usually operates with evidence. Consider replacing with words like "evidence", "demonstration", "confirmation" etc.',
    ' proves ': 'Phrases about "proves" should be considered with caution. Strict proof is possible only in math, whereas science usually operates with evidence. Consider replacing with verbs like "evidence", "demonstrate", "confirm" etc.',
    'certainly': 'Consider if this sentence needs the word "certainly". According to The Elements of Style: "Used indiscriminately by some speakers, much as others use very, to intensify any and every statement. A mannerism of this kind, bad in speech, is even worse in writing".',
    ' fact ': 'Check if the word "fact" is actually applied to a fact. According to The Elements of Style: "Use this word only of matters of a kind capable of direct verification, not of matters of judgment."',
    'highly': 'The word "highly" rarely highly contributes to better understanding. Consider removing it or, if important quantifying it.',
    'greatly': 'The word "greatly" rarely contributes to better understanding. Consider removing it or, if important quantifying it.',
    'literally': 'The word "literally" is often misused to support an exaggeration, which is hardly appropriate for a scientific paper. Consider if its use is appropriate.',
    'literal ': 'The word "literal" is often misused to support an exaggeration, which is hardly appropriate for a scientific paper. Consider if use is appropriate.',
    'respectively': 'Consider if "respectively" is necessary. In clear cases, you can omit it, e.g. "A and B are equal to 1 and 2". Or simplify it as "A = 1 and B = 2".',
    'correspondingly': 'Consider if "correspondingly" is necessary. In clear cases, you can omit it, e.g. "A and B are equal to 1 and 2". Or simplify it as "A = 1 and B = 2".',
    'best': 'If the word "best" serves here to qualify results or methods, it will be considered hype and should be avoided. Consider replacing it with "optimal" or "reasonable" or just removing it.',
    'Best': 'If the word "best" serves here to qualify results or methods, it will be considered hype and should be avoided. Consider replacing it with "optimal" or "reasonable" or just removing it.',
    'It is known': 'It is known that phrases like "It is known" should be avoided. Often, it is not actually known to the readers. Just state the fact and supply a reference.',
    'it is known': 'It is known that phrases like "it is known" should be avoided. Often, it is not actually known to the readers. Just state the fact and supply a reference.',
    'are well known': 'It is well known that phrases with "are well known" are considered arrogant. Usually, is it not so well known to the reader. Consider removing it or at least supplying the references.',
    'is well known': 'It is well known that phrases with "is well known" are considered arrogant. Usually, is it not so well known to the reader. Consider removing it or at least supplying the references.',
    'the first time': 'If "the first time" refers to the findings, try to find a better way to claim novelty of the work because such expressions are often considered hype and discouraged by journals. Try using verbs already suggesting the novelty, like "uncover", "invent", "resolve", "solve", "propose" etc.',
    'the very first time': 'If "the very first time" refers to the findings, try to find a better way to claim novelty of the work because such expressions are often considered hype and discouraged by journals. Try using verbs already suggesting the novelty, like "uncover", "invent", "resolve", "solve", "propose" etc.',

    # Questionable patterns

    'been attracting a great attention': 'Attracted attention is not necessarily a good motivation for research. Consider a stronger motivation. Moreover, this phrase is overused.',
    'attracted a great attention': 'Attracted attention is not necessarily a good motivation for research. Consider a stronger motivation. Moreover, this phrase is overused.',
    'attracted great attention': 'Attracted attention is not necessarily a good motivation for research. Consider a stronger motivation. Moreover, this phrase is overused.',
    'attracted attention': 'Attracted attention is not necessarily a good motivation for research. Consider a stronger motivation. Moreover, this phrase is overused.',
    'One of the most': 'Consider rewriting it without "One of the most". According to the Elements of Style: "There is nothing wrong in this; it is simply threadbare and forcible-feeble."',
    'one of the most': 'Consider rewriting it without "one of the most". According to the Elements of Style: "There is nothing wrong in this; it is simply threadbare and forcible-feeble."',
    'This shows': 'It might be unclear what "This" points to if the previous phrase was complicated. Rewrite with a more specific subject, e.g. "This trend shows".',
    'This demonstrates': 'It might be unclear what "This" points to if previous phrase was complicated. Rewrite with a more specific subject, e.g. "This experiment demonstrates".',
    'This proves': 'It might be unclear what "This" points to if the previous phrase was complicated. Rewrite with a more specific subject, e.g. "This experiment proves".',
    'This is': 'It might be unclear what "This is" points to if the previous phrase was complicated. Rewrite with a more specific subject, e.g. "This value is".',
    'This leads': 'It might be unclear what "This leads" points to if the previous phrase was complicated. Rewrite with a more specific subject, e.g. "This result leads".',
    'et al ': 'Needs a period after "et al". For example "Alferov et al. showed".',
    'convincing proof': 'Usually proof if by definition convincing, so you may omit the word "convincing".',

    # Spelling out the abbreviations

    'FORTRAN': 'Uncapitalize "FORTRAN" as "Fortran" for clearer look.',
    'COMSOL': 'Uncapitalize "COMSOL" as "Comsol" for clearer look.',
    'APPOLO': 'Uncapitalize "APPOLO" as "Appolo" for clearer look.',
    'ELMER': 'Uncapitalize "ELMER" as "Elmer" for clearer look.',

    # Zombie nouns

    'made a decision': 'Rewrite using the verb "decided" instead of zombie noun "decision".',
    'make a decision': 'Rewrite using the verb "decide" instead of zombie noun "decision".',
    'performed the measurement': 'Rewrite using the verb "measured" instead of zombie noun "measurement".',
    'made the measurement': 'Rewrite using the verb "measured" instead of zombie noun "measurement".',
    'make the measurement': 'Rewrite using the verb "measure" instead of zombie noun "measurement".',
    'take into consideration': 'Rewrite using the verb "consider" instead of zombie noun "consideration".',
    'is in agreement': 'Rewrite using the verb "agrees" instead of zombie noun "agreement".',
    'is in good agreement': 'Rewrite using the verb "agrees" instead of zombie noun "agreement".',
    'are in agreement': 'Rewrite using the verb "agree" instead of zombie noun "agreement".',
    'are in good agreement': 'Rewrite using the verb "agree" instead of zombie noun "agreement".',
    'was in agreement': 'Rewrite using the verb "agreed" instead of zombie noun "agreement".',
    'is an indication of': 'Rewrite using the verb "indicate" instead of zombie noun "indication".',
    'is indication of': 'Rewrite using the verb "indicate" instead of zombie noun "indication".',
    'are indication of': 'Rewrite using the verb "indicate" instead of zombie noun "indication".',
    'have a tendency': 'Rewrite using the verb "tend" instead of zombie noun "tendency".',
    'has a tendency': 'Rewrite using the verb "tends" instead of zombie noun "tendency".',
    'have tendency': 'Rewrite using the verb "tend" instead of zombie noun "tendency".',
    'has tendency': 'Rewrite using the verb "tends" instead of zombie noun "tendency".',
    'indications of': 'Rewrite using the verb "indicate" instead of zombie noun "indications".',
    'indication of': 'Rewrite using the verb "indicate" instead of zombie noun "indication".',
    'suggestive of': 'Rewrite using the verb "suggest" instead of construction with "suggestive of".',
    'indicative of': 'Rewrite using the verb "indicate" instead of construction with "indicative of".',

    # Inconcise expressions

    ' is known to ': 'Try rewriting without vague "is known to", e.g. rewrite "A is known to cause B" as "A causes B".',
    ' are known to ': 'Try rewriting without vague "are known to", e.g. rewrite "A are known to cause B" as "A causes B".',
    'a variety of': 'Replace "a variety of" with shorter "various".',
    'by means of': 'Usually, "by means of" can be replaced with shorter "by" or "using".',
    'By means of': 'Usually, "By means of" can be replaced with shorter "By" or "Using".',
    'It is important to note': 'Consider replacing long "It is important to note" with just "Note".',
    'In this work': 'You may replace "In this work" with shorter "Here" or just start with "We show that".',
    'In this article': 'You may replace "In this article" with just "Here, ..." or just start with "We show that".',
    'In this paper': 'You may replace "In this article" with just "Here, ..." or just start with "We show that".',
    'In recent years': 'Consider replacing "In recent years" with shorter "Recently" or more specific "Since 1999".',
    'make it possible': 'Consider replacing "make it possible" with shorter "enable".',
    'makes it possible': 'Consider replacing "makes it possible" with shorter "enables".',
    'in a reliable manner': 'Consider replacing "in a reliable manner" with shorter "reliably".',
    'Consequently': 'Consider replacing "Consequently" with shorter "Thus" or "Hence".',
    'In the meantime': 'Consider replacing "In the meantime" with shorter "Meanwhile".',
    # 'Therefore': 'Consider replacing "Therefore" with shorter "Thus" or "Hence".',
    'therefore': 'Consider replacing "therefore" with shorter "thus" or "hence".',
    'Nevertheless': 'You may consider replacing "Nevertheless" with shorter "Yet" or "But".',
    # 'However': 'You may consider replacing "However" with shorter "Yet" or "But".',
    'In addition,': 'You may consider replacing "In addition" with shorter "Also" or "But".',
    'For this reason': 'Consider replacing "For this reason" with shorter "Thus" or "Hence".',
    'For these reasons': 'Consider replacing "For these reasons" with shorter "Thus" or "Hence".',
    'similarly': 'Consider replacing "similarly" with "alike", e.g. "A and B look alike".',
    'Similarly,': 'Consider replacing "Similarly" with "Likewise".',
    'In contrast to': 'Consider replacing "In contrast to" with shorter "Unlike".',
    'In contrast with': 'Consider replacing "In contrast with" with shorter "Unlike".',
    'Similarly to this,': 'Consider replacing "Similarly to this" with shorter "Likewise".',
    'Similarly to the ': 'Consider replacing "Similarly to the" with shorter "Like".',
    'Owning to the fact that': 'Consider replacing "Owning to the fact that" with simple "Since" or "Because".',
    'owning to the fact that': 'Consider replacing "owning to the fact that" with simple "since" or "because".',
    'In spite of the fact that': 'Consider replacing "In spite of the fact that" with simple "Although".',
    'in spite of the fact that': 'Consider replacing "in spite of the fact that" with simple "though".',
    'in spite of ': 'Consider replacing "in spite of" with shorter "despite".',
    'Despite the fact that': 'Consider replacing "Despite the fact that" with simple "Although".',
    'despite the fact that': 'Consider replacing "despite the fact that" with simple "though".',
    'Considering the fact that': 'Consider replacing "Considering the fact that" with simple "Since" or "Because".',
    'considering the fact that': 'Consider replacing "considering the fact that" with simple "since" or "because".',
    'Regardless of the fact that': 'Consider replacing "Regardless of the fact that" with simple "Although".',
    'regardless of the fact that': 'Consider replacing "regardless of the fact that" with simple "although".',
    'With regard to': 'Consider replacing "With regard to" with shorter "About" or "Regarding".',
    'with regard to': 'Consider replacing "with regard to" with shorter "about" or "regarding".',
    'in the neighborhood of': 'Consider replacing "in the neighborhood of" with shorter "about".',
    'Given the fact that': 'Consider replacing "Given the fact that" with simple "Since" or "Because".',
    'given the fact that': 'Consider replacing "given the fact that" with simple "since" or "because".',
    'Due to the fact that': 'Consider replacing "Due to the fact that" with simple "Because".',
    'due to the fact that': 'Consider replacing "due to the fact that" with simple "because".',
    'It is interesting to note that': 'Consider removing "It is interesting to note that". According to Craft of Scientific Writing: "If the detail is not interesting, then the writer should not include it".',
    ' the fact that': 'Consider replacing "the fact that" with just "that".',
    'as to whether': 'Consider shortening "as to whether" as just "whether".',
    'In order to': 'Consider shortening "In order to" as just "To".',
    'in order to': 'Consider shortening "in order to" as just "to".',
    'utilize': 'Replace "utilize" with simple "use".',
    'utilise': 'Replace "utilise" with simple "use".',
    'utilization': 'Replace "utilization" with simple "use".',
    'utilisation': 'Replace "utilisation" with simple "use".',
    'elevated temperature': 'Replace "elevated" with simpler "higher".',
    'conception': 'Consider replacing "conception" with "concept".',
    'the ways in which': 'Consider replacing "the ways in which" with a simple "how".',
    'on the other hand': 'In some cases, you may replace "on the other hand" with shorter "however" or "but".',
    'On the other hand': 'In some cases, you may replace "On the other hand" with shorter "However" or "But".',
    'for the purpose of': 'Consider replacing "for the purpose of" with shorter "for".',
    'For the purpose of': 'Consider replacing "For the purpose of" with shorter "For".',
    'For the reason that': 'Consider replacing "For the reason that" with shorter "Because" or "As".',
    'for the reason that': 'Consider replacing "for the reason that" with shorter "because" or "as".',
    'not only': 'If you are using the construction "A is not only B but also C", there might be a better way to phrase it, e.g. "A is B. Moreover, A is also C".',
    'in light of the fact that': 'Consider replacing "in light of the fact that" with simple "because".',
    'In light of the fact that': 'Consider replacing "In light of the fact that" with simple "Because".',
    'in the event that': 'Consider replacing "in the event that" with simple "if" or "when".',
    'In the event that': 'Consider replacing "In the event that" with simple "If" or "when".',
    'under circumstances in which': 'Consider replacing "under circumstances in which" with simple "if" or "when".',
    'Under circumstances in which': 'Consider replacing "Under circumstances in which" with a simple "If" or "When".',
    'on the occasion of': 'Consider replacing "on the occasion of" with simple "when".',
    'On the occasion of': 'Consider replacing "On the occasion of" with a simple "When".',
    'it is crucial that': 'Consider rewriting the phrase with "it is crucial that" using simple "must" or "should".',
    'it is necessary that': 'Consider rewriting the phrase with "it is necessary that" using simple "must" or "should".',
    'it is important that': 'Consider rewriting the phrase with "it is important that" using simple "must" or "should".',
    'it is necessary to ': 'Consider rewriting the phrase with "it is necessary to" using simple "must" or "should".',
    'it is important to ': 'Consider rewriting the phrase with "it is important to" using simple "must" or "should".',
    ' is able to': 'Consider replacing "is able to" with simple "can".',
    ' are able to': 'Consider replacing "are able to" with simple "can".',
    ' was able to': 'Consider replacing "was able to" with simple "could".',
    ' were able to': 'Consider replacing "were able to" with simple "could".',
    'has the opportunity to': 'Consider replacing "has the opportunity to" with simple "can".',
    'have the opportunity to': 'Consider replacing "have the opportunity to" with simple "can".',
    'is in a position to': 'Consider replacing "is in a position to" with simple "can".',
    'are in a position to': 'Consider replacing "are in a position to" with simple "can".',
    'has the capacity for': 'Consider replacing "has the capacity for" with simple "can".',
    'have the capacity for': 'Consider replacing "have the capacity for" with simple "can".',
    'has the ability to': 'Consider replacing "has the ability to" with simple "can".',
    'have the ability to': 'Consider replacing "have the ability to" with simple "can".',
    'has the potential to': 'Consider replacing "has the potential to" with simple "can".',
    'have the potential to': 'Consider replacing "have the potential to" with simple "can".',
    'it is possible that': 'Consider rewriting the phrase with "it is possible that" using simple "may", "might", "can", or "could".',
    'It is possible that': 'Consider rewriting the phrase with "It is possible that" using simple "may", "might", "can", or "could".',
    'there is a chance that': 'Consider rewriting the phrase with "there is a chance that" using simple "may", "might", "can", or "could".',
    'There is a chance that': 'Consider rewriting the phrase with "There is a chance that" using simple "may", "might", "can", or "could".',
    'it could happen that': 'Consider rewriting the phrase with "it could happen that" using simple "may", "might", "can", or "could".',
    'It could happen that': 'Consider rewriting the phrase with "It could happen that" using simple "may", "might", "can", or "could".',
    'the possibility exists': 'Consider rewriting the phrase with "the possibility exists" using simple "may", "might", "can", or "could".',
    'The possibility exists': 'Consider rewriting the phrase with "The possibility exists" using simple "may", "might", "can", or "could".',
    'prior to': 'Consider replacing "prior to" with simple "before".',
    'Prior to': 'Consider replacing "Prior to" with simple "Before".',
    'in anticipation of': 'Consider replacing "in anticipation of" with a simple "before".',
    'In anticipation of': 'Consider replacing "In anticipation of" with simple "Before".',
    'subsequent to': 'Consider replacing "subsequent to" with simple "after".',
    'at the same time as': 'Consider replacing "at the same time as" with a simple "as".',
    'At the same time as': 'Consider replacing "At the same time as" with a simple "As".',
    'question as to whether': 'Consider replacing "the question as to whether" with a simple "whether".',
    'question of whether': 'In "question of whether" you can omit "of".',
    'simultaneously with': 'Consider replacing "simultaneously with" with a simple "as".',
    'Simultaneously with': 'Consider replacing "Simultaneously with" with a simple "As".',
    'facilitate': 'Replace "facilitate" with simple "help". According to The Craft Of Scientific Writing: "Words such as facilitate are pretentious".',
    'great many': 'Replace "great many" with just "many".',
    'Great many': 'Replace "Great many" with just "Many".',
    'large number of': 'Consider replacing "large number of" with just "many".',
    'great number of': 'Consider replacing "great number of" with just "many".',
    'Great number of': 'Consider replacing "Great number of" with just "Many".',
    'Big number of': 'Consider replacing "Big number of" with just "Many".',
    'big number of': 'Consider replacing "big number of" with just "many".',
    'At this point in time': 'Consider replacing "At this point in time" with just "Now" or "Today".',
    'at this point in time': 'Consider replacing "at this point in time" with just "now" or "today".',
    'At this moment in time': 'Consider replacing "At this moment in time" with just "Now" or "Today".',
    'at this moment in time': 'Consider replacing "at this moment in time" with just "now" or "today".',
    'In a case in which': 'Consider replacing "In a case in which" with just "If" or "When".',
    'in a case in which': 'Consider replacing "in a case in which" with just "if" or "when".',
    'by way of': 'Consider replacing "by way of" with just "by" or "using".',
    'As a matter of fact': 'Consider replacing "As a matter of fact" with "In fact" or just omitting it.',
    'as a matter of fact': 'Consider replacing "as a matter of fact" with "in fact" or just omitting it.',
    'at all times': 'Consider replacing "at all times" with shorter "always".',
    'In the absence': 'Consider replacing "In the absence" with "Without".',
    'in the absence': 'Consider replacing "in the absence" with "without".',
    'Because of the fact that': 'Consider replacing "Because of the fact that" with just "Because".',
    'because of the fact that': 'Consider replacing "because of the fact that" with just "because".',
    'Owing to the fact that': 'Consider replacing "Owing to the fact that" with just "Because".',
    'owing to the fact that': 'Consider replacing "owing to the fact that" with just "because".',
    'in the vicinity of': 'Consider replacing "in the vicinity of" with just "near".',
    'we believe': 'Consider writing what you believe directly, without starting with "we believe".',
    'We believe': 'Consider writing what you believe directly, without starting with "We believe".',
    'I believe': 'Consider writing what you believe directly, without starting with "I believe".',
    'would like to': 'Consider removing "would like to" and writing the next verb directly, e.g. "We (would like to) emphasize that"',
    'At the temperature of': 'Consider shortening "At the temperature of" to just value, e.g. "At 4 K".',
    'At temperature of': 'Consider shortening "At temperature of" to just value, e.g. "At 4 K".',
    'at the temperature of': 'Consider shortening "at the temperature of" to just value, e.g. "at 4 K".',
    'at temperature of': 'Consider shortening "at temperature of" to just value, e.g. "at 4 K".',
    'along the lines of': 'Consider replacing "along the lines of" with shorter "like".',
    'majority of': 'Consider replacing "majority of" with shorter "most".',
    'adequate number of': 'Consider replacing "adequate number of" with shorter "enough".',
    'give an indication': 'Consider replacing "give an indication" with shorter "show".',
    'gives an indication': 'Consider replacing "gives an indication" with shorter "shows".',
    'has an effect on': 'Consider replacing "has an effect on" with shorter "affects".',
    'have an effect on': 'Consider replacing "have an effect on" with shorter "affect".',
    'has the capacity to': 'Consider replacing "has the capacity to" with shorter "can".',
    'have the capacity to': 'Consider replacing "have the capacity to" with shorter "can".',
    'on a daily basis': 'Consider replacing "on a daily basis" with shorter "daily".',
    'have a preference for': 'Consider replacing "have a preference for" with shorter "prefer".',
    'has a preference for': 'Consider replacing "has a preference for" with shorter "prefers".',
    'had a preference for': 'Consider replacing "had a preference for" with shorter "preferred".',
    'methodology': 'Consider replacing "methodology" with shorter "method".',
    'subsequent': 'Consider replacing "subsequent" with shorter "later".',
    'modify': 'Consider replacing "modify" with simpler "change".',
    'modified': 'Consider replacing "modified" with simpler "changed".',
    'modifies': 'Consider replacing "modifies" with simpler "changes".',
    'modifications': 'Consider replacing "modifications" with simpler "changes".',
    'modification ': 'Consider replacing "modification" with simpler "change".',
    'component': 'Consider replacing "component" with simpler "part".',
    'indication': 'Consider replacing word "indication" with simpler "sign". "Short words are best" - W. Churchill"',
    'although it is': 'Consider replacing "although it is" with shorter "albeit".',
    'although it was': 'Consider replacing "although it was" with shorter "albeit".',
    'although it becomes': 'Consider replacing "although it becomes" with shorter "albeit".',
    'two times': 'You may replace "two times" with shorter "twice".',
    'various different': 'You may replace "various different" with just "various".',
    'based on the assumption': 'Consider replacing "based on the assumption" with simpler "assuming" or just "if".',
    'under the assumption': 'Consider replacing "under the assumption" with simpler "assuming" or just "if".',
    'assuming that': 'Consider replacing "assuming that" with a simple "if". "Short words are best" - W. Churchill',
    'Assuming that': 'Consider replacing "Assuming that" with a simple "if". "Short words are best" - W. Churchill',
    'Based on the assumption': 'Consider replacing "Based on the assumption" with simpler "Assuming" or just "If".',
    'have long been known to be': 'Consider replacing "have long been known to be" with simple "are".',
    'has long been known to be': 'Consider replacing "has long been known to be" with simple "is".',

    # Replace "to be" with a verb

    'is beginning': 'Consider replacing "is beginning" with simple "begins".',
    'are beginning': 'Consider replacing "are beginning" with simple "begin".',
    'is following': 'Consider replacing "is following" with simple "follows".',
    'are following': 'Consider replacing "are following" with simple "follow".',
    'is used to detect': 'Consider replacing "is used to detect" with simple "detects".',
    'was used to detect': 'Consider replacing "was used to detect" with simple "detected".',
    'is dependent': 'Consider replacing "is dependent" with simple "depends".',
    'are dependent': 'Consider replacing "are dependent" with simple "depends".',

    # Empty adjectives

    'detailed': 'Consider if adjective "detailed" really adds anything here.',
    'fundamental': 'Consider if adjective "fundamental" really adds anything here.',

    # Overused words

    'clearly': 'The word "clearly" is clearly overused in science and often points to things that clearly are not so clear. Consider removing it.',
    ' clear ': 'The word "clear" is overused in science and often points to things that actually are not so clear. Consider if it is necessary here.',
    ' clear.': 'The word "clear" is overused in science and often points to things that actually are not so clear. Consider if it is necessary here.',
    ' clear,': 'The word "clear" is overused in science and often points to things that actually are not so clear. Consider if it is necessary here.',
    'clearly demonstrate': 'According to The Craft Of Scientific Writing: "When someone uses "clearly demonstrate" more often than not those results do not clearly demonstrate anything at all".',
    'unambiguous': 'According to The Craft Of Scientific Writing: "The word "unambiguous" is arrogant; it defies the reader to question the figure".',
    'obviously': 'The word "obviously" is often misused in science and might describe something that is not so obvious. Consider removing it.',
    'Obviously': 'The word "Obviously" is often misused in science and might describe something that is not so obvious. Obviously, consider removing it.',
    'Basically': 'The word "Basically" is basically not very appropriate for academic writing. Basically, consider removing it.',
    'basically': 'The word "basically" is basically not very appropriate for academic writing. Basically, consider removing it.',
    'obvious ': 'The word "obvious" is often misused in science and might describe something that is not so obvious. It also annoys readers. Consider removing it.',
    'strongly': 'The word "strongly" is often strongly misused to describe not so strong things. Strongly consider removing it and expressing the strength quantitatively, e.g. "42% stronger".',
    'strong ': 'The word "strong" is often misused to describe not so strong things. Consider if the usage here is appropriate.',
    'significantly': 'The word "significantly" is often significantly misused and vague. It might mean statistically significant or significant to the author. State significance quantitatively, e.g. "increased by 42%". Other alternatives: "substantially, notably"',
    'significant ': 'The word "significant" is often misused and vague. It might mean statistically significant or significant to the author. State significance quantitatively, e.g. "by 42%". Other alternatives: "substantial, notable"',
    # ' while': 'It might be better to replace "while" with "whereas", unless it really happens simultaneously. Simple phrases like "A is white, while B is red" can be simplified as "A is white; B is red."',

    # Random corrections

    'less then': 'Probably "then" should be changed to "than" if this is a comparison.',
    'more then': 'Probably "then" should be changed to "than" if this is a comparison.',
    'higher then': 'Probably "then" should be changed to "than" if this is a comparison.',
    'lower then': 'Probably "then" should be changed to "than" if this is a comparison.',
    'bigger then': 'Probably "then" should be changed to "than" if this is a comparison.',
    'smaller then': 'Probably "then" should be changed to "than" if this is a comparison.',
    'larger then': 'Probably "then" should be changed to "than" if this is a comparison.',
    'better then': 'Probably "then" should be changed to "than" if this is a comparison.',
    'micrometer': 'To avoid confusion with a device called "micrometer", you can use "micron" for units.',
    ' data is': 'The word "data" is plural, double-check if "data is" is correct.',
    ' data has': 'The word "data" is plural, double-check if "data has" is correct.',
    ' data shows': 'The word "data" is plural, double-check if "data shows" is correct.',
    ' 0 ': 'Simple numbers 0-10 are better to be spelled out, e.g. "five samples", "above zero", "equal to one".',
    'and/or': 'Try to say it without "and/or" monstrosity. Often, just "and" or "or" is enough.',
    'or/and': 'Try to say it without "or/end" monstrosity. Often, just "and" or "or" is enough.',
    'generate ': 'Verify that the verb "generate" really describes a generation process. Otherwise, consider replacing it with "cause".',
    'generated': 'Verify that the verb "generated" really describes a generation process. Otherwise, consider replacing it with "caused".',
    'generating': 'Verify that "generating" really describes a generation process. Otherwise, consider replacing it with "causing".',
    'In conclusions': 'Correct as "In conclusion".',
    ' the the ': 'Seems like "the" is repeated twice,',
    ' a a ': 'Seems like "a" is repeated twice,',
    ' an an ': 'Seems like "a" is repeated twice,',
    'Eq. (': 'Brackets around the equation number are usually unnecessary, e.g. Eq. 1., check guidelines for your journal.',
    'Co.': 'Full stop is not required after Co, i.e. just "and Co" is fine.',
    ' --- ': 'Usually, m-dash does not have spaces around it. e.g. "Photons---quanta of light---have no mass.", but it is a matter of style.',
    ' allow': 'Check if the verb "allow" is related to some permissions. If you mean "make it possible", use the verb "enable".',
    ' insure': 'Check if "insure" is not mistaken for "ensure". If you mean "make sure" use "ensure".',
    'propagate as long': 'Verify that you do not mean "propagate as far" instead of "propagate as long".',
    'propagates as long': 'Verify that you do not mean "propagates as far" instead of "propagates as long".',
    'propagated as long': 'Verify that you do not mean "propagated as far" instead of "propagated as long".',
    'propagating as long': 'Verify that you do not mean "propagating as far" instead of "propagating as long".',
    'travel as long': 'Verify that you do not mean "travel as far" instead of "travel as long".',
    'travels as long': 'Verify that you do not mean "travels as far" instead of "travels as long".',
    'traveled as long': 'Verify that you do not mean "traveled as far" instead of "traveled as long".',
    'traveling as long': 'Verify that you do not mean "traveling as far" instead of "traveling as long".',
    'travelled as long': 'Verify that you do not mean "travelled as far" instead of "traveled as long".',
    'travelling as long': 'Verify that you do not mean "travelling as far" instead of "traveling as long".',
    r'$\hslash$ is the reduced Planck': 'It is safe to assume that all physicists know the meaning of h-bar.',
    r'$\hslash$ is the Planck': 'It is safe to assume that all physicists know the meaning of h-bar.',
    r'$\hslash$ is Planck': 'It is safe to assume that all physicists know the meaning of h-bar.',
    r'$\hbar$ is the reduced Planck': 'It is safe to assume that all physicists know the meaning of h-bar.',
    r'$\hbar$ is the Planck': 'It is safe to assume that all physicists know the meaning of h-bar.',
    r'$\hbar$ is Planck': 'It is safe to assume that all physicists know the meaning of h-bar.',
    'irregardless': 'Replace "irregardless" with "regardless".',
    'Monte-Carlo': 'Spell "Monte-Carlo" without a hyphen, i.e. "Monte Carlo".',
    'have to have': 'Replace "have to have" with "must have" or "should have".',
    'has to have': 'Replace "have to have" with "must have" or "should have".',
    'everyone of ': 'Correct "everyone of" as "every one of".',
    ' an other ': 'Correct "an other" as "another".',
    ' is comprised of ': 'Correct "is comprised of" as "comprises". The whole comprises its parts.',
    ' are comprised of ': 'Correct "are comprised of" as "comprise". The whole comprises its parts.',
    ' onboard ': 'Correct "onboard" as "on-board".',
    ' cause and affect': 'Correct as "cause and affect" as "cause and effect".',
    'carefully chosen': 'The word "carefully" does not add much here. The act of choice already implies some consideration.',
    'carefully selected': 'The word "carefully" does not add much here. The act of selection already implies some consideration.',
    'carefully select': 'The word "carefully" does not add much here. The act of selection already implies some consideration.',
    'carefully choose': 'The word "carefully" does not add much here. The act of choice already implies some consideration.',
    'low frequency range': 'Correct as "low-frequency".',
    'high frequency range': 'Correct as "high-frequency".',
    'high frequency vibration': 'Correct as "high-frequency".',
    'low frequency vibration': 'Correct as "low-frequency".',
    'high frequency phonon': 'Correct as "high-frequency".',
    'low frequency phonon': 'Correct as "low-frequency".',
    'straight curve': 'Usually a line is either straight or curved. Consider replacing "straight curve" with "straight line".',
    'linear curve': 'Usually a linear dependence is not curved. Consider replacing "linear curve" with "line".',
    'before hand': 'Beforehand is spelled as one word.',
    'different than': 'Correct "different than" as "different from".',

    # Numbers next to words

    '2-layer': 'Spell out simple numbers like "two-layer".',
    '3-layer': 'Spell out simple numbers like "three-layer".',
    '4-layer': 'Spell out simple numbers like "four-layer".',
    '2-beam': 'Spell out simple numbers like "two-beam".',
    '3-beam': 'Spell out simple numbers like "three-beam".',
    '4-beam': 'Spell out simple numbers like "four-beam".',
    '2-fold': 'Spell out simple numbers like "two-fold".',
    '3-fold': 'Spell out simple numbers like "three-fold".',
    '4-fold': 'Spell out simple numbers like "four-fold".',
    '5-fold': 'Spell out simple numbers like "five-fold".',
    '2-body': 'Spell out simple numbers like "two-body".',
    '3-body': 'Spell out simple numbers like "three-body".',

    # Increases as temperature is increased

    'increases as the temperature is increased': 'The phrase "increases as the temperature is increased" can be simplified as "increases with temperature.',
    'increase as the temperature is increased': 'The phrase "increase as the temperature is increased" can be simplified as "increase with temperature.',
    'increased as the temperature is increased': 'The phrase "increased as the temperature is increased" can be simplified as "increase with temperature.',
    'increase as the temperature was increased': 'The phrase "increase as the temperature was increased" can be simplified as "increased with temperature.',
    'increased as the temperature was increased': 'The phrase "increased as the temperature was increased" can be simplified as "increased with temperature.',

    # Referring to figures

    ' fig.': 'Most journals prefer capitalized references to figures, e.g. "as shown in Fig. 1".',
    ' figs.': 'Most journals prefer capitalized references to figures, e.g. "as shown in Figs. 1-2".',
    '[Fig': 'Most journals prefer regular brackets for figure references, e.g. (Fig. 1).',
    '(see Fig': 'You can omit the word "see" in the figure reference, e.g. (Fig. 1).',
    '(see fig': 'You can omit the word "see" in the figure reference, e.g. (Fig. 1).',
    '(as shown in Fig': 'You can omit the words "as shown in" in the figure reference, e.g. (Fig. 1).',
    '(shown in Fig': 'You can omit the words "shown in" in the figure reference, e.g. (Fig. 1).',
    '(see SI': 'You can omit the word "see" in the SI reference, e.g. (Supplementary Information S1).',
    '(see Supp': 'You can omit the word "see" in the figure reference, e.g. (Supplementary Figure S1).',
    '(see SM': 'You can omit the word "see" in the figure reference, e.g. (Supplementary Figure S1).',
    '(see Methods': 'You can omit the word "see" in the Methods reference and just write (Methods).',
    '(see Appendix': 'You can omit the word "see" in the Appendix reference and just write (Appendix 1).',

    # Shortened units

    'thousands of K ': 'Consider spelling our the units as kelvin',
    'hundreds of K ': 'Consider spelling our the units as kelvin',
    'tens of K ': 'Consider spelling our the units as kelvin',
    'few K ': 'Consider spelling our the units as kelvin',
    'several K ': 'Consider spelling our the units as kelvin',
    'thousands of K.': 'Consider spelling our the units as kelvin',
    'hundreds of K.': 'Consider spelling our the units as kelvin',
    'tens of K.': 'Consider spelling our the units as kelvin',
    'few K.': 'Consider spelling our the units as kelvin',
    'several K.': 'Consider spelling our the units as kelvin',
    'thousands of µm': 'Consider spelling out the units as microns',
    'hundreds of µm': 'Consider spelling out the units as microns',
    'tens of µm': 'Consider spelling out the units as microns',
    'few µm': 'Consider spelling out the units as microns',
    'several µm': 'Consider spelling our the units as microns',
    'thousands of nm': 'Consider spelling our the units as nanometers instead of nm',
    'hundreds of nm': 'Consider spelling our the units as nanometers instead of nm',
    'tens of nm': 'Consider spelling our the units as nanometers instead of nm',
    'few nm': 'Consider spelling our the units as nanometers instead of mm',
    'several nm': 'Consider spelling our the units as nanometers instead of nm',
    'thousands of mm': 'Consider spelling our the units as millimeters instead of mm',
    'hundreds of mm': 'Consider spelling our the units as millimeters instead of nm',
    'tens of mm': 'Consider spelling our the units as millimeters instead of mm',
    'few mm': 'Consider spelling our the units as millimeters instead of mm',
    'several mm': 'Consider spelling our the units as millimeters instead of mm',

    # Numbers instead of words

    '100s of ': 'Write "hundreds of" instead of "100s of "',
    '10s of ': 'Write "tens of" instead of "100s of "',
    '1000s of ': 'Write "thousands of" instead of "100s of "',
    '1000000s of ': 'Write "millions of" instead of "100s of "',

    # Passive voice

    'has been observed': 'Consider rewriting the sentence with "has been observed" in active voice, e.g. "we observed that".',
    'have been observed': 'Consider rewriting the sentence with "have been observed" in active voice, e.g. "we observed that".',
    'have been demonstrated': 'Consider rewriting the sentence with "have been demonstrated" in active voice, e.g. "we demonstrated that".',
    'has been demonstrated': 'Consider rewriting the sentence with "has been demonstrated" in active voice, e.g. "we demonstrated that".',
    'has been shown': 'Consider rewriting the sentence with "has been shown" in active voice, e.g. "we showed that".',
    'have been shown': 'Consider rewriting the sentence with "have been shown" in active voice, e.g. "we showed that".',
    'have been investigated': 'Consider rewriting the sentence with "have been investigated" in active voice, e.g. "researchers investigated the effect".',
    'has been investigated': 'Consider rewriting the sentence with "has been investigated" in active voice, e.g. "researchers investigated the effect".',
    'have been studied': 'Consider rewriting the sentence with "have been studied" in active voice, e.g. "researchers studied the effect".',
    'has been studied': 'Consider rewriting the sentence with "has been studied" in active voice, e.g. "researchers studied the effect".',
    'was observed': 'Consider rewriting the sentence with "was observed" in active voice, e.g. "we observed that".',
    'were observed': 'Consider rewriting the sentence with "were observed" in active voice, e.g. "we observed that".',
    'were demonstrated': 'Consider rewriting the sentence with "were demonstrated" in active voice, e.g. "we demonstrated that".',
    'was demonstrated': 'Consider rewriting the sentence with "was demonstrated" in active voice, e.g. "we demonstrated that".',
    'was shown': 'Consider rewriting the sentence with "was shown" in active voice, e.g. "we showed that".',
    'were shown': 'Consider rewriting the sentence with "were shown" in active voice, e.g. "we showed that".',
    'were investigated': 'Consider rewriting the sentence with "were investigated" in active voice, e.g. "researchers investigated the effect".',
    'was investigated': 'Consider rewriting the sentence with "was investigated" in active voice, e.g. "researchers investigated the effect".',
    'were studied': 'Consider rewriting the sentence with "were studied" in active voice, e.g. "researchers studied the effect".',
    'was studied': 'Consider rewriting the sentence with "was studied" in active voice, e.g. "researchers studied the effect".',

    # Inappropriate language

    "it's": 'If you mean "it is", it is better just to write "it is". Otherwise, it might need to be corrected as "its", e.g. "material and its properties".',
    "it`s": 'If you mean "it is", it is better just to write "it is". Otherwise, it might need to be corrected as "its", e.g. "material and its properties".',
    'kind of': 'Consider kind of replacing "kind of" with "rather" or kind of avoiding it completely.',
    'pretty much': 'Consider pretty much deleting "pretty much".',
    ' and so on.': 'Try to rewrite without "...and so on". It might be too informal and vague if other items in the list are unclear. Either list all important items or generalize the remaining, for example "Voyager flew past Mars, Jupiter, and other planets.',
    ' and so forth': 'Try to rewrite without "...and so on". It might be too informal and vague if other items in the list are unclear. Either list all important items or generalize the remaining, for example "Voyager flew past Mars, Jupiter, and other planets.',
    'sort of': 'Consider sort of replacing "sort of" with "rather" or sort of avoiding it completely.',
    ' less ': 'Verify that "less" is not misused for "fewer" (e.g. "less time", but "fewer samples") or cannot be replaced with a more precise word like "thinner", "shorter", "weaker" etc.',
    ' very ': 'Consider if the word "very" is very very necessary. If the emphasis is required, use words strong in themselves or quantify the statement.',
    ' these days.': 'These days we consider "these days" too informal. Consider omitting or using "recently".',
    'viewpoint': 'Consider replacing with "point of view".',
    "don't": "Most academic journals prefer do not instead of don't.",
    "isn't": "Most academic journals prefer is not instead of isn't.",
    "wasn't": "Most academic journals prefer was not instead of wasn't.",
    "doesn't": "Most academic journals prefer does not instead of doesn't.",
    "wouldn't": "Most academic journals prefer would not instead of wouldn't.",
    "shouldn't": "Most academic journals prefer should not instead of shouldn't.",
    'it is': 'Avoid constructions with "it is" since they obscure the main subject and action of a sentence.',
    'there is': 'Avoid constructions with "there is" since they obscure the main subject and action of a sentence.',
    'there are': 'Avoid constructions with "there are" since they obscure the main subject and action of a sentence.',
    'It is': 'Avoid constructions with "It is" since they obscure the main subject and action of a sentence.',
    'There is': 'Avoid constructions with "There is" since they obscure the main subject and action of a sentence.',
    'There are': 'Avoid constructions with "There are" since they obscure the main subject and action of a sentence.',
    'Actually': 'The word "Actually" might actually be unnecessary.',
    'actually': 'The word "actually" might actually be unnecessary.',
    'really': 'The word "really" might be really unnecessary.',
    'years': 'Instead of "years", it might be better to give the exact year of the event.',
    'a bit ': 'Consider replacing informal "a bit" with a bit more formal "somewhat" or removing it completely.',
    'a lot of': 'Consider replacing "a lot of" with "many" or "several", or just give the exact number.',
    'A lot of': 'Consider replacing "A lot of" with "Many" or "Several", or just give the exact number.',
    'You ': 'Using "You" might be inappropriate in academic writing. Consider using "One", e.g. "One can see...".',
    'you ': 'Using "you" might be inappropriate in academic writing. Consider using "One", e.g. "One can see...".',
    'And ': 'Instead of starting this sentence with "And" try just removing it.',
    ' thing': 'The word "thing" is rather vague, try to be more specific.',
    'Dear Editor': 'Consider to address your dear editor by the real name.',
    'Dear editor': 'Consider to address your dear editor by the real name.',
    'Firstly': 'In modern English "First" is preferred to "Firstly".',
    'firstly': 'In modern English "first" is preferred to "firstly".',
    'Secondly': 'In modern English "Second" is preferred to "Secondly".',
    'secondly': 'In modern English "second" is preferred to "secondly".',
    'diminish ': 'If by "diminish" you mean that something is decreasing, consider replacing with "decrease".',
    'diminishing ': 'If by "diminishing" you mean that something is decreasing, consider replacing with "decreasing".',
    'diminished ': 'If by "diminished" you mean that something is decreasing, consider replacing with "decreased".',
    'So,': 'Beginning with "So" might seem so informal. So, consider replacing it with "Thus,".',
    'So ': 'Beginning with "So" might seem so informal. So, consider replacing it with "Thus".',
    'By the way': '"By the way" might seem too informal.',
    'stand for': '"stand for" might seem too informal. Consider "represent".',
    'stands for': '"stands for" might seem too informal. Consider "represents".',
    'leave out': '"leave out" might seem too informal. Consider "omit".',
    'think about': '"think about" might seem too informal. Consider "consider".',
    'point out': '"point out" might seem too informal. Consider "indicate".',

    # Latinisms

    'radiuses': 'Preferably replace "radiuses" with "radii".',
    'axises': 'Correct "axises" as "axes".',
    'thesises': 'Correct "thesises" as "theses".',
    'bacteriums': 'Correct "bacteriums" as "bacteria".',
    'erratums': 'Correct "erratums" as "errata".',
    'analysises': 'Correct "analysises" as "analyses".',
    'appendixes': 'Correct "appendixes" as "appendices".',
    'stimuluses': 'Correct "stimuluses" as "stimuli".',
    'vortexes': 'Correct "vortexes" as "vortices".',
    'ab initio ': 'Consider if your readers know the Latin expressions "ab initio". Consider replacing with "from first principles" or similar.',
    'in vitro ': 'Consider if your readers know the Latin expressions "in vitro" or if there might be a more common term.',
    'in vivo ': 'Consider if your readers know the Latin expressions "in vivo" or if there might be a more common term.',
    'e.g.': 'Consider if your readers know the Latin expressions "e.g.". It might be better to write "for example".',
    'i.e.': 'Consider if your readers know the Latin expressions "i.e.". It might be better to write "that is".',
    'in silico ': 'Consider if your readers know the Latin expressions "in silico" or if there might be a more common term.',
    'in utero': 'Consider if your readers know the Latin expressions "in utero" or if there might be a more common term.',
    'in situ ': 'Consider if your readers know the Latin expressions "in situ" or if there might be a more common term.',
    'ex vivo ': 'Consider if your readers know the Latin expressions "ex vivo" or if there might be a more common term.',
    'vs.': 'Consider if your readers know the Latin expressions "vs.". It might be better to replace with "against" or "as a function of".',
    'a.k.a.': 'Consider replacing "a.k.a." with "also known as" for clarity.',
    ' aka ': 'Consider replacing "aka" with "also known as" for clarity.',
    ' p.a.': 'Consider replacing "p.a." with "per year" for clarity.',
    ' ad hoc': 'Consider replacing "ad hoc" with "improvised" for clarity.',

    # Latex best practices

    r'$\mu$m': r'You may replace LaTeX expression "$\mu$m" with "{\\textmu}m" for better looking letter mu.',
    r'$\mu$s': r'You may replace LaTeX expression "$\mu$m" with "{\\textmu}s" for better looking letter mu.',
    r'$\mu$g': r'You may replace LaTeX expression "$\mu$m" with "{\\textmu}g" for better looking letter mu.',
    r'$\mu$TDTR': r'You may replace LaTeX expression "$\mu$TDTR" with "{\\textmu}TDTR" for better looking letter mu.',
    r'\hslash': r'If by "\hslash" you mean the reduced Planck constant, use "\hbar".',
    '+/-': r'If you are in LaTeX, use "\pm" instead of "+/-". Otherwise, find proper plus-minus symbol.',
    r' $^\circ$C': 'Degrees Celsius should not be separated from the number with a space',
    r' $^\circ$F': 'Degrees Fahrenheit should not be separated from the number with a space.',
    }

# This list of cliches was taken from suspense.net:
# Web Page: http://suspense.net/whitefish/cliche.htm
# Email: suspense@suspense.net 

CLICHES = set([
    "Hallmark",
    "paradigm shift",
    "At the end of the day",
    "at the end of the day",
    "In a nutshell",
    "in a nutshell",
    "Holy Grail",
    "holy grail",
    "ace up your sleeve",
    "all talk, no action",
    "all booster, no payload",
    "all hat, no cattle",
    "all hammer, no nail",
    "all icing, no cake",
    "all shot, no powde",
    "all sizzle, no steak",
    "all wax and no wick",
    "all that and a bag of chips",
    "all thumbs",
    "all wet",
    "all's fair in love and wa",
    "almighty dolla",
    "always a bridesmaid",
    "ambulance chase",
    "armchair quarterback",
    "army brat",
    "art imitates life",
    "as luck would have it",
    "as old as time",
    "back against the wall",
    "back in the saddle",
    "back to square one",
    "back to the drawing board",
    "bad to the bone",
    "ballpark figure",
    "baptism of fire",
    "bare bones",
    "bark is worse than the bite",
    "bark up the wrong tree",
    "bats in the belfry",
    "beat around the bush",
    "beat the bushes",
    "better late than never",
    "better safe than sorry",
    "between a rock and a hard place",
    "beyond the pale",
    "big as life",
    "big fish in a small pond",
    "big man on campus",
    "bird in the hand",
    "bite the dust",
    "bitter disappointment",
    "black as coal",
    "blast from the past",
    "bleeding heart",
    "blind as a bat",
    "blood is thicker than water",
    "blood money",
    "blood on your hands",
    "blood, sweat and tears",
    "blow this joint",
    "boil it down to",
    "boils down to",
    "booze and broads",
    "bored to tears",
    "born and raised",
    "born yesterday",
    "bottom line",
    "brain drain",
    "brain dump",
    "brass tacks",
    "bring home the bacon",
    "broken record",
    "bull by the horns",
    "bull in a china shop",
    "bump in the night",
    "busy as a bee",
    "by and large",
    "calm before the storm",
    "candle at both ends",
    "case of mistaken identity",
    "cat out of the bag",
    "caught red-handed",
    "checkered caree",
    "chickens come home to roost",
    "chomping at the bit",
    "cleanliness is next to godliness",
    "clear as a bell",
    "clear as mud",
    "cold shoulde",
    "could care less",
    "couldn't care less",
    "couldn't get to first base",
    "count your blessings",
    "countless hours",
    "creature comfort",
    "crime in the street",
    "curiosity killed the cat",
    "cut a fine figure",
    "cut and dried",
    "cut to the chase",
    "cut to the quick",
    "cute as a button",
    "darkest before the dawn",
    "dead as a doornail",
    "death and taxes",
    "death's doorstep",
    "devil is in the details",
    "dog in the mange",
    "don't count your chickens before they're hatched",
    "don't do the crime if you can't do the time",
    "doubting Thomas",
    "down and dirty",
    "down in the dumps",
    "down pat",
    "down the drain",
    "down the toilet",
    "down the hatch",
    "down to earth",
    "drive you up a wall",
    "dyed in the wool",
    "ear to the ground",
    "early bird catches the worm",
    "easier said than done",
    "easy as 1-2-3",
    "easy as pie",
    "eat crow",
    "eat humble pie",
    "enough already",
    "every dog has its day",
    "every fiber of my being",
    "everything but the kitchen sink",
    "evil twin",
    "existential angst",
    "experts agree",
    "eye for an eye",
    "facts of life",
    "fair-haired one",
    "fair weather friend",
    "fall off of a turnip truck",
    "fat slob",
    "favor us with a song",
    "fear and loathing",
    "feather your nest",
    "fellow travele",
    "few and far between",
    "field this one",
    "fifteen minutes of fame",
    "fish nor fowl",
    "fly by night",
    "fly the coop",
    "for the birds",
    "fox in the henhouse",
    "freudian slip",
    "fun and games",
    "fun in the sun",
    "garbage in, garbage out",
    "get the sack",
    "get your groove back",
    "gets my goat",
    "gift horse in the mouth",
    "gilding the lily",
    "give a damn",
    "give me a break",
    "gives me the creeps",
    "go him one bette",
    "goes without saying",
    "good deed for the day",
    "good time was had by all",
    "Greek to me",
    "green thumb",
    "green-eyed monste",
    "grist for the mill",
    "guiding light",
    "hair of the dog",
    "hard to believe",
    "have a nice day",
    "head honcho",
    "heart's content",
    "hell-bent for leathe",
    "hidden agenda",
    "high on the hog",
    "hold a candle to",
    "hold your horses",
    "hold your tongue",
    "hook or by crook",
    "horse of a different color",
    "hot knife through butte",
    "how goes the battle",
    "if the shoe fits",
    "in a pinch",
    "in a wink",
    "in harm's way",
    "in the tank",
    "in your dreams",
    "in your face",
    "inexorably drawn",
    "info dump",
    "influence peddling",
    "intents and purposes",
    "it was a dark and stormy night",
    "it won't fly",
    "Jack of all trades",
    "jockey for position",
    "Johnny-come-lately",
    "joined at the hip",
    "jump down your throat",
    "jump in with both feet",
    "jump on the bandwagon",
    "jump the gun",
    "jump her bones",
    "jump his bones",
    "junk in the trunk",
    "jury is still out",
    "justice is blind",
    "keep an eye on you",
    "keep it down",
    "keep it simple, stupid",
    "keep up with the Joneses",
    "keep your cards close to vest",
    "keep your chin up",
    "keep your fingers crossed",
    "keep your powder dry",
    "kick ass",
    "kickbutt",
    "kick the bucket",
    "kick up your heels",
    "kick you to the curb",
    "kick your feet up",
    "kid in a candy store",
    "kill two birds with one stone",
    "King's English",
    "king's ransom",
    "kiss and tell",
    "kiss of death",
    "kit and kaboodle",
    "knee-high to a grasshoppe",
    "knock it out of the park",
    "knock on wood",
    "knock your socks off",
    "knocked up",
    "know him from Adam",
    "know the ropes",
    "know the score",
    "knuckle down",
    "knuckle sandwich",
    "knuckle unde",
    "labor of love",
    "lap of luxury",
    "last but not least",
    "last-ditch effort",
    "last hurrah",
    "law of the jungle",
    "law of the land",
    "lay down the law",
    "leaps and bounds",
    "let sleeping dogs lie",
    "let the cat out of the bag",
    "let's split",
    "lie like a rug",
    "life and limb",
    "life imitates art",
    "life's a bitch",
    "lighten up",
    "lights out",
    "like a sore thumb",
    "like butter",
    "like the plague",
    "like there's no tomorrow",
    "lion's share",
    "litmus test",
    "little black book",
    "live and learn",
    "long and short of it",
    "long lost love",
    "look before you leap",
    "lounge lizard",
    "loved and lost",
    "low man on the totem pole",
    "luck of the draw",
    "luck of the Irish",
    "make my day",
    "male chauvinist",
    "man's best friend",
    "many moons",
    "many-splendored thing",
    "mark my words",
    "meaningful relationship",
    "mellow out",
    "moment of glory",
    "moment's respite",
    "Monday morning quarterback",
    "monkey suit",
    "monkey see, monkey do",
    "motherhood and apple pie",
    "movers and shakers",
    "moving experience",
    "my two cents",
    "neat as a pin",
    "needless to say",
    "nip it in the bud",
    "no guts, no glory",
    "no love lost",
    "no pain, no gain",
    "no stone unturned",
    "no time like the present",
    "nose to the grindstone",
    "not in my back yard",
    "not on your tintype",
    "number one fan",
    "numerous to mention",
    "off the wagon",
    "old college try",
    "old meets new",
    "older and wise",
    "older than dirt",
    "older than Methuselah",
    "on the bandwagon",
    "on the nose",
    "on the wagon",
    "on thin ice",
    "one born every minute",
    "one foot in the grave",
    "one in a million",
    "only game in town",
    "only to be met",
    "out of pocket",
    "out of the frying pan",
    "out on a limb",
    "panic button",
    "party pooper",
    "patter of little feet",
    "pass the sniff test",
    "pay through the nose",
    "peas in a pod",
    "perfect storm",
    "pig in a poke",
    "pillar of society",
    "plenty of fish in the sea",
    "poison pen",
    "poor as a churchmouse",
    "poor excuse for",
    "pot calling the kettle black",
    "proud possessor",
    "put my foot down",
    "put your foot down",
    "quick as a bunny",
    "quick and the dead",
    "rags to riches",
    "raining buckets",
    "raining cats and dogs",
    "rank and file",
    "read my lips",
    "red herring",
    "redheaded stepchild",
    "reign supreme",
    "remember the alamo",
    "road to hell is paved with good intentions",
    "rob Peter to pay Paul",
    "rock and a hard place",
    "rocket science",
    "rocket scientist",
    "rope a dope",
    "run it up the flagpole",
    "running dog lackey",
    "safe than sorry",
    "salt of the earth",
    "save face",
    "scared stiff",
    "scared to death",
    "school's out",
    "screaming meemies",
    "senses reel",
    "set the record straight",
    "shake a stick should of",
    "shoulder to the wheel",
    "shouldered his way",
    "shut your trap",
    "sigh of relief",
    "significant other",
    "silence is golden",
    "slept like a log",
    "small world",
    "snake in the grass",
    "snow job",
    "snug as a bug",
    "some of my best friends",
    "something the cat dragged in",
    "spade a spade",
    "spare the rod",
    "spitting image",
    "spring to life",
    "squeaky wheel gets the grease",
    "squeaky wheel gets the oil",
    "start from scratch",
    "stick in the mud",
    "stick in your craw",
    "still waters run deep",
    "stop and smell the roses",
    "store bought",
    "stranger than fiction",
    "straw that broke the camel's back",
    "stubborn as a mule",
    "stuff that dreams are made of",
    "stuffed shirt",
    "take one for the team",
    "take the bull by the horns",
    "take the plunge",
    "takes one to know one",
    "talk turkey",
    "ten foot pole",
    "the earth moved",
    "the final analysis",
    "the real McCoy",
    "the same old story",
    "these things happen",
    "thick as thieves",
    "think outside of the box",
    "third time's the charm",
    "this day and age",
    "this point in time",
    "three strikes and you're out",
    "through the grapevine",
    "throw in the towel",
    "tiger by the tail",
    "till the fat lady sings",
    "time and time again",
    "time is of the essence",
    "tip of the iceberg",
    "to err is human",
    "to the best of my knowledge",
    "tongue-in-cheek",
    "too hot to handle",
    "touch of blarney",
    "tough as nails",
    "tough luck",
    "tough row to hoe",
    "traditional family values",
    "trials and tribulations",
    "tried and true",
    "trip down memory lane",
    "true blue",
    "turn your smile upside-down",
    "turn your frown upside-down",
    "twist of fate",
    "twists and turns",
    "two to tango",
    "under the gun",
    "under the same roof",
    "understated elegance",
    "unexpected twist",
    "until the cows come home",
    "up his sleeve",
    "up the creek",
    "up the wrong tree",
    "very real concern",
    "view with alarm",
    "wakeup call",
    "was my face red",
    "watch your tongue",
    "web of intrigue",
    "week of Sundays",
    "what a bummer",
    "what comes around, goes around",
    "what the cat dragged in",
    "what the dickens",
    "what the heck",
    "what the hell",
    "what you see is what you get",
    "when push comes to shove",
    "when rubber meets the road",
    "when the cat's away",
    "when the going gets tough, the tough get going",
    "who has everything",
    "whole ball of wax",
    "whole hog",
    "whole nine yards",
    "whole other story",
    "wild goose chase",
    "wild oats",
    "will wonders never cease",
    "win friends and influence people",
    "win one for the Gippe",
    "winning is everything",
    "wisdom of the ages",
    "without benefit of clergy",
    "wolf at the doo",
    "words fail",
    "work like a dog",
    "worst nightmare",
    "wrong side of the bed",
    "years young",
    "yellow journalism",
    "you are what you eat",
    "you can run, but you can't hide",
    "you know what they say",
    "young and foolish",
    "young and restless",
    "yuppie",
    "20/20 hindsight",
    "His elevator doesn't go to the top floor",
    "All foam, no bee",
    "His bread ain't done",
    "His yeast went bad",
    "He couldn't pour water out of a boot with instructions printed on the heel",
    "The cheese slid off his cracker",
    "The light is on, but nobody is home.",
    "There's nothing in the attic but cobwebs.",
    "The wheel is turning, but the hamster is dead.",
    "Body by Fisher, brains by Mattel.",
    "The gates are down, the lights are flashing, but there is no train.",
    "Somewhere a village is missing its idiot",
    "He donated his brain to science. Science sent it back.",
    "He fell out of the Stupid Tree and hit every branch on his way down.",
    "The starting gate is open, but he's still asking directions.",
    "A few cans short of a six-pack.",
    "His pilot light isn't lit.",
    "If brains were dynamite, he couldn't blow his nose.",
    "It takes him an hour to cook Minute Rice."
    ])

REDUNDANT = {
    'PM in the afternoon': 'PM',
    'AM in the morning': 'AM',
    'necessary requirements': 'requirements',
    'necessary requirement ': 'requirement',
    'smaller in size': 'smaller',
    'future candidate': 'candidate',
    'larger in size': 'larger',
    'bigger in size': 'bigger',
    'most unique': 'unique',
    'resultant effect': 'result',
    'end result': 'result',
    'pooled together': 'pooled',
    'assemble together': 'assemble',
    'fewer in number': 'fewer',
    'exactly the same': 'the same',
    'revert back': 'revert',
    'reverted back': 'reverted',
    'shorter in length': 'shorter',
    'longer in length': 'longer',
    'summarize briefly': 'summarize',
    'briefly summarize': 'summarize',
    'a total of': 'ten samples',
    'A total of': 'Ten samples',
    'close proximity': 'proximity',
    'each and every': 'each',
    'Each and every': 'Each',
    'make a study of': 'study',
    'made a study of': 'studied',
    'conduct an investigation of': 'investigate',
    'conduct investigation of': 'investigate',
    'conduct the investigation of': 'investigate',
    'conducted an investigation of': 'investigated',
    'conducted investigation of': 'investigated',
    'conducted the investigation of': 'investigated',
    'already exist': 'exist',
    'alternative choice': 'choice',
    'basic fundamentals': 'fundamentals',
    'continue to remain': 'remain',
    'continues to remain': 'remains',
    'remains still': 'remains',
    'remain still': 'remain',
    'still remain': 'remain',
    'currently being': 'being',
    'currently underway': 'underway',
    'empty space': 'space',
    'introduce a new': 'introduce',
    'introduced a new': 'introduced',
    'mix together': 'mix".',
    'never before': 'never',
    'period of time': 'period',
    'separate entities': 'entities',
    'still persist': 'persist',
    'return back': 'return',
    'returned back': 'returned',
    'true fact': 'fact',
    'repeated again': 'repeated',
    'repeating again': 'repeated',
    'repeat again': 'repeated',
    'already has been': 'has been',
    'already have been': 'have been',
    'join together': 'join',
    'joined together': 'join',
    'might possibly': 'might',
    'might perhaps': 'might',
    'must necessarily': 'must',
    'must inevitably': 'must',
    'must necessary': 'must',
    'must definitely': 'must',
    'previous experience': 'experience',
    'prior experience': 'experience',
    'past experience': 'experience',
    'first conceived': 'conceived',
    'actual fact': 'fact',
    'advance forward': 'advance',
    'add an additional': 'add',
    'added bonus': 'bonus',
    'all-time record': 'record',
    'and etc.': 'etc.',
    'anonymous stranger': 'stranger',
    'annual anniversary': 'anniversary',
    'ask the question': 'ask',
    'ATM machine': 'ATM',
    'bald-headed': 'bald',
    'best ever': 'best',
    'bouquet of flowers': 'bouquet',
    'brief in duration': 'brief',
    'cacophony of sound': 'cacophony',
    'careful scrutiny': 'scrutiny',
    'cash money': 'cash',
    'classify into groups': 'classify',
    'commute back and forth': 'commute',
    'compete with each other': 'compete',
    'component part': 'part',
    'confused state': 'confused',
    'constantly maintained': '',
    'crisis situation': 'crisis',
    'current trend': 'trend',
    'depreciate in value': 'depreciate',
    'depreciates in value': 'depreciates',
    'depreciated in value': 'depreciated',
    'desirable benefit': 'benefit',
    'disappear from sight': 'disappear',
    'disappeared from sight': 'disappeared',
    'earlier in time': '',
    'eliminate altogether': 'eliminate',
    'emergency situation': 'emergency',
    'enclosed herein': 'enclosed',
    'enter in ': 'enter',
    'entirely eliminate': 'eliminate',
    'equal to one another': 'equal',
    'equals to one another': 'equal',
    'eradicate completely': 'eradicate',
    'estimated at about': 'estimated at',
    'evolve over time': 'evolve',
    'exact same': 'same',
    'face mask': 'mask',
    'few in number': 'few',
    'first and foremost': 'first',
    'First and foremost': 'First',
    'first of all': 'first',
    'First of all': 'First',
    'fly through the air': 'fly',
    'follow after': 'follow',
    'foreign imports': 'imports',
    'free gift': 'gift',
    'full satisfaction': 'satisfaction',
    'general public': 'public',
    'GRE exam': 'GRE',
    'grow in size': 'grow',
    'harmful injuries': 'injuries',
    'harmful injury': 'injury',
    'HIV virus': 'HIV',
    'hollow tube': 'tube',
    'incredible to believe': 'incredible',
    'integrate with each other': 'integrate',
    'integrated with each other': 'integrated',
    'interdependent on each other': 'interdependent',
    'irregardless': 'regardless',
    'joint collaboration': 'collaboration',
    'knowledgeable expert': 'expert',
    'lag behind': 'lag',
    'LCD display': 'LCD',
    'little baby': 'baby',
    'local resident': 'resident',
    'look back in retrospect': 'look back',
    'manually by hand': 'manually',
    'meet with each other': 'meet',
    'mental telepathy': 'telepathy',
    'mutual cooperation': 'cooperation',
    'mutually interdependent': 'interdependent',
    'mutual respect for each other': 'mutual respect',
    'natural instinct': 'instinct',
    'none at all': 'none',
    'nostalgia for the past': 'nostalgia',
    'now pending': 'pending',
    'oral conversation': 'conversation',
    'outside in the yard': 'in the yard',
    'outside of': 'outside',
    'over exaggerate': 'exaggerate',
    'pair of twins': 'twins',
    'palm of the hand': 'palm',
    'penetrate into': 'penetrate',
    'pick and choose': 'choose',
    'polar opposites': 'opposites',
    'postpone until later': 'postpone',
    'previously listed above': 'listed above',
    'proceed ahead': 'proceed',
    'pursue after': 'pursue',
    'RAM memory': 'RAM',
    'recur again': 'recur',
    'recurred again': 'recurred',
    'regular routine': 'routine',
    'round in shape': 'round',
    'same exact': 'same',
    'sand dune': 'dune',
    'scrutinize in detail': 'scrutinize',
    'scrutinized in detail': 'scrutinized',
    'separated apart from each other': 'separated',
    'serious danger': 'danger',
    'shiny in appearance': 'shiny',
    'spell out in detail': 'spell out',
    'start off': 'start',
    'sudden impulse': 'impulse',
    'sum total': 'sum',
    'surrounded on all sides': 'surrounded',
    'time period': 'period',
    'tiny bit': 'bit',
    'total destruction': 'destruction',
    'truly sincere': 'sincere',
    'two equal halves': 'halves',
    'ultimate goal': 'goal',
    'undergraduate student': 'undergraduate',
    'underground subway': 'subway',
    'universal panacea': 'panacea',
    'unnamed anonymous': 'anonymous',
    'usual custom': 'custom',
    'very unique': 'unique',
    'visible to the eye': 'visible',
    'warn in advance': 'warn',
    'whether or not': 'whether',
    'completely eliminate': 'eliminate',
    'completely fill': 'fill',
    'advance planning': 'planning',
    'absolutely essential': 'essential',
    'absolutely necessary': 'necessary',
    'unexpected surprise': 'surprise',
    'fall down': 'fall',
    'add up': 'add',
    'heat up': 'heat',
    'rise up': 'rise',
    'open up': 'open',
    'circle around': 'circle',
    'final conclusion': 'conclusion',
    'final outcome': 'outcome',
    'cancel out': 'cancel',
    'canceled out': 'canceled',
    'cancels out': 'cancels',
    'future plan': 'plan',
    'frozen ice': 'ice',
    'empty hole': 'hole',
    'major breakthrough': 'breakthrough',
    'reflect back': 'reflect',
    'reflects back': 'reflects',
    'reflected back': 'reflected',
    'personal friend': 'friend',
    'personal opinion': 'opinion',
    'soft in texture': 'soft',
    'soft to the touch': 'soft',
    'weather conditions': 'weather',
    'weather situation': 'weather',
    'introduced for the first time': 'introduced',
    'introduce for the first time': 'introduce',
    'plan ahead': 'plan',
    'plan in advance': 'plan',
    }

NEGATIVES = {
    'not able': 'unable',
    'not different': 'alike',
    'did not accept': 'rejected',
    'does not accept': 'rejects',
    'do not accept': 'reject',
    'did not consider': 'ignored',
    'have not considered': 'ignored',
    'has not considered': 'ignored',
    'do not considered': 'ignore',
    'do not allow': 'prevent',
    'did not allow': 'prevented',
    'does not allow': 'prevents',
    'does not have': 'lacks',
    'do not have': 'lack',
    'did not have': 'lacked',
    'non symmetric': 'asymmetric',
    'non-symmetric': 'asymmetric',
    'not symmetric': 'asymmetric',
    'non polarized': 'unpolarized',
    'not important': 'unimportant',
    'not known': 'unknown',
    'not significant': 'negligible',
    }

ABSOLUTES = {
    ' never ': 'According to Craft of Scientific Writing: "Never is a frightening word because it invites the readers to think of exceptions". Consider alternatives: "rarely", "seldom", "remains unclear", "remains challenging".',
    'always': 'According to Craft of Scientific Writing: "Always is a frightening word because it invites the readers to think of exceptions. You should go in fear of absolutes".',
    }

ABSOLUTES_EXCEPTIONS = [
    ['almost never'],
    ['not always', 'almost always'],
    ]

COMPLEX_WORDS = {
    'elucidate':'explain',
    'diminish': 'decrease',
    'establish': 'set',
    'depict': 'show',
    'comprehensive': 'detailed',
    'eliminate': 'remove',
    'terminate': 'finish',
    'discontinue': 'stop',
    'immense': 'great',
    'profound': 'deep',
    'extensive': 'wide',
    'substantial': 'large',
    'essential': 'important',
    'foremost': 'above all',
    'prominent': 'well known',
    'distinguished': 'well known',
    'override': 'cancel',
    'assess': 'evaluate',
    'indistinguishable': 'identical',
    'laborious': 'difficult',
    'intricate': 'complex',
    'elaborate': 'design',
    'convoluted': 'complex',
    'sophisticated': 'complex',
    'adjacent': 'near',
    'conceal': 'hide',
    'acquire': 'get',
    'execute': 'do',
    'outstanding': 'great',
    'achievement': 'result',
    'prevalent': 'dominant',
    'tremendous': 'huge',
    'infinitesimal': 'tiny',
    'substantiate': 'verify',
    }


def bad_patterns(line, index):
    '''Cross-check with the dictionary of known errors and suggest fixes'''
    mistakes = []
    for word in BAD_PATTERNS:
        if word in line:
            mistakes.append(f'Line {index + 1}. {BAD_PATTERNS[word]}')
    return mistakes


def comma_after(line, index):
    '''Check for words that usually have comma after them'''
    mistakes = []
    for word in COMMA_AFTER:
        if word in line:
            mistakes.append(
                f'Line {index + 1}. Might need a comma after "{word[:-1]}".')
    return mistakes


def phrases_with_very(line, index):
    '''Check for patterns like "very ..." in the dictionary'''
    mistakes = []
    for word in VERY:
        if word in line:
            mistakes.append(
                f'Line {index + 1}. Consider replacing "{word}" with words like "{VERY[word]}" etc'
            )
    return mistakes


def start_with_numbers(line, index):
    '''Check if a non-empty line starts with a number'''
    # Need to fix this function. It make many false positives if there is a reference list
    mistakes = []
    if line[0].isdigit():
        mistakes.append(
            f'Line {index + 1}. Avoid starting sentences with numbers. Rewrite spelling out the number, e.g. "Five samples..."'
        )
    return mistakes


def figure_references(line, index):
    '''Check for 'Fig.' in the beginning of the line or 'Figure' in the middle'''
    mistakes = []
    if len(line) > 5:
        if 'Fig.' in line[0:4] or 'Figs.' in line[0:4]:
            mistakes.append(
                f'Line {index + 1}. The word "Fig." in the beginning of a sentence can usually be spelled out, e.g. "Figure 1 shows"'
            )
        if 'Figure ' in line[7:]:
            mistakes.append(
                f'Line {index + 1}. Most journals prefer shortening the word "Figure" as "Fig." if it is not opening the sentence.'
            )
    return mistakes


def numbers_next_to_units(line, index):
    '''Check if units separated or not separated from numbers with a space'''
    mistakes = []
    for number in range(9):
        for unit in UNITS:
            if (f'{number}{unit} ' in line) or (f'{number}{unit}.' in line) or (f'{number}{unit},' in line):
                mistakes.append(
                    f'Line {index + 1}. Put a space between the digit {number} and the unit {unit}'
                )
        if (str(number) + ' %' in line) or (str(number) + r' \%' in line):
            mistakes.append(
                f'Line {index + 1}. Percent sign "%" should follow numberals without a space, i.e. {number}%'
            )
    return mistakes


def elements(text):
    '''Check how many times chemical elements occur in the text'''
    mistakes = []
    entire_text = unite_valid_lines(text)
    found_elements = []
    for element in ELEMENTS:
        occurance = entire_text.count(" " + element + " ")
        if 0 < occurance < 5:
            found_elements.append(element)

    # Advise is constructed depending on how many elements were found
    if len(found_elements) == 1:
        mistakes.append(
            f'The symbol {found_elements[0]} occurs only a few times. Since most readers do not know how to read all chemical symbols, just write actual name of the element each time. For example "silicon wafer".'
        )
    if len(found_elements) > 1:
        output_string = found_elements[0]
        found_elements[-1] = ' and ' + found_elements[-1]
        for name in found_elements[1:]:
            output_string += f', {name}'
        mistakes.append(
            f'The symbols {output_string} occur only a few times each. Since most readers do not know how to read all chemical symbols, just write actual names of the elements each time. For example "silicon wafer".'
        )
    return mistakes


def abbreviations(text):
    '''Check how many times abbreviations occur in the text'''
    # Find abbreviations as ALLCAPS or ALLCaPs strings and cut "s" at the ends
    entire_text = unite_valid_lines(text)
    all_abbreviations = re.findall(r"\b(?:[A-Z][a-z]?){2,}", entire_text)
    filtered_abbreviations = []
    for abbreviation in all_abbreviations:
        trimmed_abbreviation = abbreviation[:-1] if abbreviation[-1] == 's' else abbreviation
        filtered_abbreviations.append(trimmed_abbreviation)
    mistakes = []

    # Check how often each abbreviation occurs and comment if less than five
    found_abbreviations = []
    for unique_abbreviation in set(filtered_abbreviations):
        if (unique_abbreviation not in ELEMENTS) and (unique_abbreviation
                not in EXCEPTIONS) and (unique_abbreviation not in UNITS):
            occurance = filtered_abbreviations.count(unique_abbreviation)
            if 0 < occurance < 5:
                found_abbreviations.append(unique_abbreviation)

    # Advise is constructed depending on how many abbreviations were found
    if len(found_abbreviations) == 1:
        mistakes.append(
            f'The abbreviation {found_abbreviations[0]} occurs only a few times. Since abbreviations are hard to decrypt, just spell it out each time. It is easier to read a few words than to search for meanings of abbreviations.'
        )
    if len(found_abbreviations) > 1:
        output_string = found_abbreviations[0]
        found_abbreviations[-1] = ' and ' + found_abbreviations[-1]
        for name in found_abbreviations[1:]:
            output_string += f', {name}'
        mistakes.append(
            f'The abbreviations {output_string} occur only a few times each. Since abbreviations are hard to decrypt, just spell them out each time. It is easier to read a few words than to search for meanings of abbreviations.'
        )
    return mistakes


def in_conclusions(line, index, text):
    '''Check if we can skip In conclusions because there is already a title Conclusions'''
    mistakes = []
    if ('In conclusion') in line:
        if (('Conclusion' or 'CONCLUSION') in text[index - 1]) or (
            ('Conclusion' or 'CONCLUSION') in text[index - 2]):
            mistakes.append(
                f'Line {index + 1}. This section seems to be already titled "Conclusions", thus you may omit "In conclusion" at the beginning.'
            )
    return mistakes


def british_spelling(line, index, english):
    '''Check if spelling of some words is american/british'''
    mistakes = []
    if english == 'american':
        for word in BRITISH:
            if word in line:
                mistakes.append(
                    f'Line {index + 1}. In American English, word "{word}" is spelled as "{BRITISH[word]}".'
                )
    if english == 'british':
        for word in BRITISH:
            if BRITISH[word] in line:
                mistakes.append(
                    f'Line {index + 1}. In British English, word "{BRITISH[word]}" is spelled as "{word}".'
                )
    return mistakes


def abstract_lenght(text):
    '''Find the abstract, check its length and advise if it's too long'''
    # First search for begin{abstract}. If nothing, search for abstract{
    try:
        entire_text = unite_valid_lines(text)
        pattern = '+++'
        abstract = entire_text.replace("begin{abstract", pattern).split(pattern)
        abstract = abstract[1].replace("end{abstract", pattern).split(pattern)
        abstract = abstract[0][1:-1]
    except:
        abstract = ""
        pass
    if abstract == "":
        for line in text:
            if "abstract{" in line:
                abstract = line[9:-1]

    # Check the abstract length and comment accordingly
    words = len(abstract.split())
    symbols = len(abstract)
    mistakes = []
    if len(abstract) > 1:
        if words > 150:
            mistakes.append(
                f"Your abstract has {words} words or {symbols} characters. Many journals limit abstracts by 150 words only. Check if this is within limitations of your journal."
            )
        elif words < 50:
            mistakes.append(
                f"Your abstract has only {words} words or {symbols} characters. Seems a bit short."
            )
        else:
            mistakes.append(
                f"Your abstract has {words} words or {symbols} characters. It seems fine, but double-check if this is within limitations of your journal."
            )
    return mistakes


def title_lenght(text):
    '''Find the title, check its length and advise if it's too long'''
    title = ""
    for line in text:
        if "title{" in line:
            title = line[6:-1]
    words = len(title.split())
    symbols = len(title)
    mistakes = []
    if 1 < words > 15:
        mistakes.append(
            f'Your title has {words} words or {symbols} characters. Consider making it shorter. Some journals limit the title by 15 words only.'
        )
    return mistakes


def references(text):
    '''Find references and check their number and age. Comment if they are too old or too many'''
    # Find all unique references in the text as cite{...}
    entire_text = unite_valid_lines(text)
    all_citations = re.findall(r'cite\{[^\}]+}', entire_text)
    references = []
    for citation in all_citations:
        citation_splitted = citation.split(',')
        for reference in citation_splitted:
            reference = re.sub(r'cite\{', '', reference)
            reference = re.sub(r'\}', '', reference)
            reference = re.sub(r' ', '', reference)
            references.append(reference)
    references = list(set(references))

    # Analyse the age of the references and comment if more than 40% are old
    years = []
    try:
        years = [int(re.findall(r'\d\d\d\d', ref)[0]) for ref in references]
    except:
        pass
    mistakes = []
    if len(years) > 0:
        this_year = int(date.today().year)
        reference_ages = [this_year - year for year in years]
        older_than_ten = 100 * len([age for age in reference_ages if age > 10]) // len(years)
        older_than_five = 100 * len([age for age in reference_ages if age > 5]) // len(years)
        if older_than_five > 50 or older_than_ten > 20:
            mistakes.append(
                f"Looks like {older_than_five}% of your references are older than five years and {older_than_ten}% are even older than ten years. Mostly old references might signal poor actuality of your work to journal editors. Try to use newer references."
            )
        if len(references) > 50:
            mistakes.append(
                f"You have {len(references)} references, while most journals allow maximum of 50. Check the guidelines to see how many your journal allows."
            )

        # Analyse self-citation. Find authors and cross-check with references.
        all_authors_lines = re.findall(r'\\author[\[\]abcdefg\* ,\d]*{[^}]+}', entire_text)
        names = []
        for author_line in all_authors_lines:
            author_line = re.sub(r'\\author[\[\]abcdefg,\d]*{', '', author_line)
            author_line_splitted = author_line.split(',')
            for each_author in author_line_splitted:
                each_author_splitter = each_author.split(' ')
                for name in each_author_splitter:
                    name = re.sub(r'\}', '', name)
                    name = re.sub(r' ', '', name)
                    if name != '':
                        names.append(name)
        selfcitations = 0
        for name in names:
            for reference in references:
                if name.upper() in reference.upper():
                    selfcitations += 1
        selfcitation_percentage = 100 * selfcitations // len(references)
        if 0 < selfcitation_percentage < 20:
            mistakes.append(
                f"At least {selfcitations} out of {len(references)} references seems to be self-citations. This is acceptable, but keep it in check."
            )
        if selfcitation_percentage >= 20:
            mistakes.append(
                f"At least {selfcitations} out of {len(references)} references seems to be self-citations. Consider if you need so many self-references, it might not look good."
            )
    return mistakes


def overcitation(line, index):
    '''Check if there are too many citations in one place'''
    all_citations = re.findall(r'\\cite{[^}]+}', line)
    mistakes = []
    for citation in all_citations:
        number_of_references = len(citation.split(','))
        if number_of_references > 4:
            mistakes.append(
                f"Line {index}. There are {number_of_references} references in one place. Bloated references neither make the statement stronger nor help the reader. Consider reducing citations or just citing one review instead."
            )
    return mistakes


def intro_patterns(text):
    '''Check if some introduction words occur too often times'''
    mistakes = []
    entire_text = unite_valid_lines(text)
    for word in OVERUSED_INTRO:
        occurance = entire_text.count(word)
        occurance_percentage = occurance / len(entire_text.split(" "))
        if (0.0012 < occurance_percentage < 0.002) and (occurance > 1):
            mistakes.append(
                f'Sentences often start with "{word}". Try alternatives like "{OVERUSED_INTRO[word]}".'
            )
        if occurance_percentage > 0.002 and occurance > 1:
            mistakes.append(
                f'Sentences start with "{word}" too often. Try alternatives like "{OVERUSED_INTRO[word]}".'
            )
    return mistakes


def line_is_valid(line):
    '''Check if the line is not empty and not a Latex comment'''
    validation = False
    if len(line) > 1:
        if line[0] != '%':
            validation = True
    return validation


def unite_valid_lines(text):
    '''Remove lines that are empty or a Latex comment and unite the rest'''
    entire_text = ''
    for line in text:
        if len(line) > 1:
            if line[0] != '%':
                entire_text += line
    return entire_text


def redundancy(line, index):
    '''Check for the redundancies'''
    mistakes = []
    for word in REDUNDANT:
        if word in line:
            mistakes.append(
                f'Line {index + 1}. Replace likely redundant "{word}" with just "{REDUNDANT[word]}".'
            )
    return mistakes


def negatives(line, index):
    '''Check for the negatives'''
    mistakes = []
    for word in NEGATIVES:
        if word in line:
            mistakes.append(
                f'Line {index + 1}. Replace negative "{word}" with a more positive "{NEGATIVES[word]}".'
            )
    return mistakes


def remove_latex_syntax(line):
    '''Remove latex stuff containing dots and long syntax from the line'''
    line = re.sub(r'Fig\.', '', line)
    line = re.sub(r'Figs\.', '', line)
    line = re.sub(r'Eq\.', '', line)
    line = re.sub(r'i\.e\.', '', line)
    line = re.sub(r'et al\.', '', line)
    line = re.sub(r'e\.g\.', '', line)
    line = re.sub(r'vs\.', '', line)
    line = re.sub(r'a\.k\.a\.', '', line)
    line = re.sub(r'\d.\d', '', line)
    line = re.sub(r'\.[^ ]', '', line)
    line = re.sub(r'\\cite{[^}]+}', '', line)
    line = re.sub(r'\\ref{[^}]+}', '', line)
    line = re.sub(r'\$[^\$]+\$', '', line)
    return line


def latex_best_practices(text):
    '''Check if sentences are not on separate lines in LaTeX'''
    mistakes = []
    dots_in_line = 0
    useful_lines = 0
    for line in text:
        if line_is_valid(line):
            line = remove_latex_syntax(line)
            dots_in_line += line.count('.')
            useful_lines += 1
    if dots_in_line / useful_lines > 1.2:
        mistakes.append(
            'In LaTeX, it is considered a best practice to start each sentence from a new line.'
        )
    return mistakes


def sentence_lenght(line, index):
    '''Check if the sentence is too long'''
    mistakes = []
    line = remove_latex_syntax(line)
    sentences = line.split('.')
    if any([len(sentence) > 240 for sentence in sentences]):
        mistakes.append(
            f'Line {index + 1}. The sentence seems to be too long. Consider shortening or splitting it in two.'
        )
    return mistakes


def it_is_latex_text(text):
    '''Check if this is LaTeX document'''
    entire_text = unite_valid_lines(text)
    it_is_latex_text = (('\\begin{document}' in entire_text)
                        or ('\\documentclass' in entire_text))
    return it_is_latex_text


def absolutes(line, index):
    '''Check for words like 'always' or 'never' but except exceptions'''
    mistakes = []
    for num, word in enumerate(ABSOLUTES):
        not_exception = [
            exception not in line for exception in ABSOLUTES_EXCEPTIONS[num]
        ]
        if (word in line) and all(not_exception):
            mistakes.append(f'Line {index + 1}. {ABSOLUTES[word]}')
    return mistakes


def comparing_absolutes(line, index):
    '''Check if there are comperative absolutes like "nearly infinite"'''
    all_absolutes = re.findall(
        r"((a little( bit)?|almost|astonishingly|completely|exceedingly|extremely|highly|incredibly|more than|nearly|partly|partially|quite|somewhat|totally|unbelievably|very) (dead|disappeared|false|gone|illegal|infinite|invaluable|legal|perfect|pervasive|pregnant|professional|true|whole|vanished))",
        line)
    mistakes = []
    for phrase in all_absolutes:
        phrase = str(phrase[0])
        absolute = phrase.split(" ")[-1]
        mistakes.append(
            f'Line {index + 1}. In "{phrase}" comprative degree is applied to an absolute. Usually, it is either {absolute} or not.'
        )
    return mistakes


def number_of_times(line, index):
    '''Check if there are phrases like "hundreds of times"'''
    mistakes = []

    # Patterns like "thousands of times":
    all_patterns = re.findall(
        r"((millions|hundreds|thousands|dozens) of (times|samples))",
        line)
    for phrase in all_patterns:
        phrase_wrong = str(phrase[0])
        phrase_corrected = phrase_wrong.split(" of ")[0][:-1] + " " + phrase_wrong.split(" of ")[1]
        mistakes.append(
            f'Line {index + 1}. Consider replacing "{phrase_wrong}" with "a few {phrase_corrected}".'
        )

    # Patterns like "thousands meters":
    all_patterns = re.findall(
        r"((millions|hundreds|thousands|dozens) (times|microns|micrometers|meters|hours|people|years))",
        line)
    for phrase in all_patterns:
        phrase_wrong = str(phrase[0])
        phrase_corrected = phrase_wrong.split(" ")[0][:-1] + " " + phrase_wrong.split(" ")[1]
        mistakes.append(
            f'Line {index + 1}. Replace "{phrase_wrong}" with "a {phrase_corrected}".'
        )
    return mistakes


def in_the_name_of_law(line, index):
    '''Check if names of laws mistakenly start with an article'''
    pattern = re.compile("((T|t)he [^ ]*'s (law|distribution|equation|formula|wavelength|rule|limit|theory|radiation))")
    all_matches = pattern.findall(line)
    mistakes = []
    for match in all_matches:
        mistakes.append(f'Line {index + 1}. In "{match[0]}" probably no article "the" is needed.')
    return mistakes


def extreme_quantities(line, index):
    '''Check if adjectives like big or small match the type of quantity'''
    # Quantities that should be high or low:
    pattern = re.compile("(big|large|small) ((conductivity|conductance|resistance|diffusivity)|(thermal|electrical|interface|boundary) (conductivity|conductance|resistance|resistivity|diffusivity)|frequency|value|temperature|concentration|pressure|altitude)")
    all_matches = pattern.findall(line)
    mistakes = []
    for match in all_matches:
        mistakes.append(f'Line {index + 1}. Usually "{match[1]}" is high/low rather than "{match[0]}".')

    # Quantities that should be long or short:
    pattern = re.compile("(big|large|small) (wavelength|lifespan|length|period|time frame|time period|distance|path|mean free path|MFP)")
    all_matches = pattern.findall(line)
    for match in all_matches:
        mistakes.append(f'Line {index + 1}. Usually "{match[1]}" is long/short rather than "{match[0]}".')

    # Quantities that should be wide or narrow:
    pattern = re.compile("(big|large|small) (range|spectrum)")
    all_matches = pattern.findall(line)
    for match in all_matches:
        mistakes.append(f'Line {index + 1}. Usually "{match[1]}" is wide/narrow rather than "{match[0]}".')
    return mistakes


def cliches(line, index):
    '''Check for cliches'''
    mistakes = []
    for phrase in CLICHES:
        if phrase in line:
            mistakes.append(
                f'Line {index + 1}. The phrase "{phrase}" is considered a cliché and should be avoided.'
            )
    return mistakes


def numbers_with_s(line, index):
    '''Check for number ending with 's like in 10's'''
    mistakes = []
    error = re.findall(r"\d's", line)
    if error != []:
        mistakes.append(
            f"Line {index + 1}. Placing 's after a number might be a mistake. For example, these were 2000s with three 0s, and number 0's influence on 2000s' days was clear."
        )
    return mistakes


def difficult_words(text):
    '''Check if there are some complex word with simple synonyms'''
    mistakes = []
    found_words = []
    entire_text = unite_valid_lines(text)
    for word in COMPLEX_WORDS:
        occurance = entire_text.count(word)
        if (occurance > 0):
            found_words.append(word)
    if found_words != []:
        synonyms = ''
        errors = ''
        for word in found_words:
            synonyms += '"' + COMPLEX_WORDS[word] + '", '
            errors += '"' + word + '", '
        mistakes.append(
                f'You used some difficult words like {errors[:-2]}. Try using simple synonyms, like {synonyms[:-2]} because most readers of scientific papers are not native English speakers.'
        )
    return mistakes


def main(text, english='american'):
    '''This is the main function that runs all checks and returns the results'''
    results = []
    # Checks for LaTeX-specific issues:
    if it_is_latex_text(text):
        results += title_lenght(text)
        results += abstract_lenght(text)
        results += references(text)
        results += latex_best_practices(text)

    # General checks:
    results += intro_patterns(text)
    results += elements(text)
    results += abbreviations(text)
    results += difficult_words(text)

    # Checks for each line which is not a comment:
    for index, line in enumerate(text):
        if line_is_valid(line):
            results += bad_patterns(line, index)
            results += phrases_with_very(line, index)
            results += in_conclusions(line, index, text)
            results += comma_after(line, index)
            results += figure_references(line, index)
            # results += start_with_numbers(line, index)
            results += numbers_next_to_units(line, index)
            results += british_spelling(line, index, english)
            results += overcitation(line, index)
            results += redundancy(line, index)
            results += negatives(line, index)
            results += absolutes(line, index)
            results += sentence_lenght(line, index)
            results += comparing_absolutes(line, index)
            results += cliches(line, index)
            results += numbers_with_s(line, index)
            results += in_the_name_of_law(line, index)
            results += extreme_quantities(line, index)
            results += number_of_times(line, index)

    if len(results) == 0:
        results = ["Looks like this text is perfect!"]
    return results


# Read AngryReviewerEnglish option from vim:
try:
    english_opt = vim.vars["AngryReviewerEnglish"]
    if type(english_opt) == bytes:
        english_opt = english_opt.decode()
    if english_opt not in ['american', 'british']:
        raise ValueError
except KeyError:
    print("[WARNING] g:AngryReviewerEnglish not set, (using american english)")
    english_opt = 'american'
except ValueError:
    print("[WARNING] g:AngryReviewerEnglish must be 'american' or 'british', (using american english)")
    english_opt = 'american'

# Read the buffer and send it for processing:
text = list(vim.current.buffer)
results = main(text, english=english_opt)

# Open results in a quickfix-window:
vim.command('call setqflist([], "r")')  # clear qflist
for result in results:
    lnum = '1'
    qfitem = result

    result_has_lnum = re.search('Line .', result)
    if result_has_lnum:
        lnum_search = re.search(r'\d+', result)
        lnum = lnum_search[0]
        qfitem = result[lnum_search.end()+2:]  # Clip text following Line xx.\s

    vim.command('call setqflist([{"bufnr": bufnr(""), "lnum": '+lnum+', "text": \''+qfitem.replace("'", "''") +'\'}], "a")')

vim.command('copen | setlocal nonu nornu wrap linebreak colorcolumn=0')
vim.command('echo "SUGGESTIONS FOR YOUR TEXT GENERATED"')

EOF

endfunction
