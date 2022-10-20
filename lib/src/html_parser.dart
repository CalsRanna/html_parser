import 'package:html/dom.dart';
import 'package:xpath_selector/xpath_selector.dart';
import 'package:xpath_selector_html_parser/xpath_selector_html_parser.dart';

import 'rule.dart';

class HtmlParser {
  XPathNode<Node> query(String html) {
    return HtmlXPath.html(html).root;
  }

  List<XPathNode<Node>> parseNodes(XPathNode<Node> node, String? rule) {
    if (rule == null || rule.isEmpty) {
      return <XPathNode<Node>>[];
    }
    final rules = _generateRules(rule);
    List<XPathNode<Node>> nodes = [];
    for (var item in rules) {
      if (item.protocol == RuleProtocol.xpath) {
        nodes = _pipeRuleForNodes(node, item);
      } else {
        nodes = _pipeFunctionForNodes(nodes, item);
      }
    }
    return nodes;
  }

  String parse(XPathNode<Node> node, String? rule) {
    if (rule == null || rule.isEmpty) {
      return '';
    }
    String string = '';
    final rules = _generateRules(rule);
    for (var item in rules) {
      if (item.protocol == RuleProtocol.xpath) {
        string = _pipeRule(node, item);
      } else {
        string = _pipeFunction(string, item);
      }
    }
    return string;
  }

  List<Rule> _generateRules(String rule) {
    var patterns = rule.split('|');
    List<Rule> rules = [];
    for (var item in patterns) {
      rules.add(Rule.from(rule: item));
    }
    return rules;
  }

  List<XPathNode<Node>> _pipeRuleForNodes(XPathNode<Node> node, Rule rule) {
    return node.queryXPath(rule.rule).nodes;
  }

  String _pipeRule(XPathNode<Node> node, Rule rule) {
    String string;
    switch (rule.attribute) {
      case RuleAttribute.href:
        string = node.queryXPath(rule.rule).node?.attributes['href'] ?? '';
        break;
      case RuleAttribute.src:
        string = node.queryXPath(rule.rule).node?.attributes['src'] ?? '';
        break;
      case RuleAttribute.text:
        string = node.queryXPath(rule.rule).node?.text ?? '';
        break;
      default:
        string = '';
        break;
    }
    return string;
  }

  List<XPathNode<Node>> _pipeFunctionForNodes(
      List<XPathNode<Node>> nodes, Rule rule) {
    if (rule.function.startsWith('sublist')) {
      final params = rule.function
          .replaceAll('sublist', '')
          .replaceAll('(', '')
          .replaceAll(')', '')
          .split(',');
      final start = int.parse(params.first.trim());
      final end = params.length >= 2 ? int.parse(params.last.trim()) : null;
      return nodes.sublist(start, end);
    } else {
      return nodes;
    }
  }

  String _pipeFunction(String string, Rule rule) {
    if (rule.function.startsWith('substring')) {
      final params = rule.function
          .replaceAll('substring', '')
          .replaceAll('(', '')
          .replaceAll(')', '')
          .split(',');
      final start = int.parse(params.first.trim());
      final end = params.length >= 2 ? int.parse(params.last.trim()) : null;
      return string.substring(start, end);
    } else if (rule.function.startsWith('replace')) {
      final params = rule.function
          .replaceAll('replace', '')
          .replaceAll('(', '')
          .replaceAll(')', '')
          .replaceAll('\'', '')
          .replaceAll('"', '')
          .split(',');
      final from = params.first;
      final replace = params.length >= 2 ? params.last : '';
      return string.replaceAll(from, replace);
    } else {
      return '';
    }
  }
}
