class Rule {
  RuleAttribute attribute = RuleAttribute.nodes;
  String function = '';
  RuleProtocol protocol = RuleProtocol.xpath;
  String rule = '';

  Rule.from({required String rule}) {
    final attribute = rule.split('@').last;
    switch (attribute) {
      case 'href':
        this.attribute = RuleAttribute.href;
        break;
      case 'src':
        this.attribute = RuleAttribute.src;
        break;
      case 'text':
        this.attribute = RuleAttribute.text;
        break;
      default:
        break;
    }
    if (rule.startsWith('function:')) {
      this.attribute = RuleAttribute.none;
      protocol = RuleProtocol.function;
      function = rule.replaceAll('function:', '');
    } else {
      this.rule = rule.replaceAll('xpath:', '').replaceAll('@$attribute', '');
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

enum RuleAttribute { href, nodes, none, src, text }

enum RuleProtocol { function, xpath }
