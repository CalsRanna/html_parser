class Rule {
  String attribute = 'nodes';
  String function = '';
  String protocol = 'xpath';
  String rule = '';

  Rule.from({required String value}) {
    attribute = value.split('@').last;
    const unsupportedAttribute = ['class', 'id'];
    if (unsupportedAttribute.contains(attribute)) {
      attribute = '';
    }
    if (value.startsWith('function:')) {
      attribute = '';
      protocol = 'function';
      function = value.replaceAll('function:', '');
    } else if (value.startsWith(r'$')) {
      protocol = 'jsonpath';
      rule = value;
    } else {
      rule = value.replaceAll('$protocol:', '').replaceAll('@$attribute', '');
    }
  }

  @override
  String toString() {
    return {
      'attribute': attribute,
      'function': function,
      'protocol': protocol,
      'rule': rule,
    }.toString();
  }
}
