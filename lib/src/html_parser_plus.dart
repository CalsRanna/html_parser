import 'dart:convert';

import 'package:html/dom.dart';
import 'package:json_path/json_path.dart';
import 'package:xpath_selector/xpath_selector.dart';
import 'package:xpath_selector_html_parser/xpath_selector_html_parser.dart';

import 'rule.dart';

class HtmlParser {
  HtmlParserNode parse(String html) {
    try {
      return HtmlParserNode()..jsonNode = jsonDecode(html);
    } catch (error) {
      return HtmlParserNode()..xpathNode = HtmlXPath.html(html).root;
    }
  }

  String query(HtmlParserNode node, String? rule) {
    String result = '';
    if (rule == null || rule.isEmpty) {
      return result;
    }
    final rules = _generateRules(rule);
    for (var item in rules) {
      if (item.protocol == 'function') {
        result = _pipeFunction(result, item);
      } else {
        result = _pipeRule(node, item);
      }
    }
    return result;
  }

  List<HtmlParserNode> queryNodes(HtmlParserNode node, String? rule) {
    List<HtmlParserNode> results = [];
    if (rule == null || rule.isEmpty) {
      return results;
    }
    final rules = _generateRules(rule);
    for (var item in rules) {
      if (item.protocol == 'function') {
        results = _pipeFunctionForNodes(results, item);
      } else {
        results = _pipeRuleForNodes(node, item);
      }
    }
    return results;
  }

  List<Rule> _generateRules(String rule) {
    var patterns = rule.split('|');
    List<Rule> rules = [];
    for (var item in patterns) {
      rules.add(Rule.from(value: item));
    }
    return rules;
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
    } else if (rule.function.startsWith('trim')) {
      return string.trim();
    } else if (rule.function.startsWith('replaceRegExp')) {
      final params = rule.function
          .replaceAll('replaceRegExp', '')
          .replaceAll('(', '')
          .replaceAll(')', '')
          .replaceAll('\'', '')
          .replaceAll('"', '')
          .split(',');
      final from = params.first;
      var replace = params.length >= 2 ? params.last : '';
      replace = replace.replaceAll(r'\n', '\n');
      replace = replace.replaceAll(r'\u2003', '\u2003');
      return string.replaceAll(RegExp(from), replace);
    } else if (rule.function.startsWith('replace')) {
      final params = rule.function
          .replaceAll('replace', '')
          .replaceAll('(', '')
          .replaceAll(')', '')
          .replaceAll('\'', '')
          .replaceAll('"', '')
          .replaceAll(r'\n', '\n')
          .replaceAll(r'\u2003', '\u2003')
          .split(',');
      final from = params.first;
      final replace = params.length >= 2 ? params.last : '';
      return string.replaceAll(from, replace);
    } else {
      return string;
    }
  }

  List<HtmlParserNode> _pipeFunctionForNodes(
      List<HtmlParserNode> nodes, Rule rule) {
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

  String _pipeRule(HtmlParserNode node, Rule rule) {
    if (node.xpathNode != null) {
      final nodes = node.xpathNode!.queryXPath(rule.rule).nodes;
      String? result;
      switch (rule.attribute) {
        case 'html':
          result = nodes.map((item) => item.node.parent?.innerHtml).join();
          break;
        case 'text':
          result = nodes.map((item) => item.text).join('\n');
          break;
        default:
          result = nodes.map((item) => item.attributes[rule.attribute]).join();
          break;
      }
      return result;
    } else {
      final match = JsonPath(rule.rule).read(node.jsonNode!);
      if (match.isNotEmpty) {
        return match.first.value.toString();
      } else {
        return '';
      }
    }
  }

  List<HtmlParserNode> _pipeRuleForNodes(HtmlParserNode node, Rule rule) {
    if (node.xpathNode != null) {
      final nodes = node.xpathNode!.queryXPath(rule.rule).nodes;
      return nodes.map((item) => HtmlParserNode()..xpathNode = item).toList();
    } else {
      final match = JsonPath(rule.rule).read(node.jsonNode!);
      if (match.isNotEmpty) {
        final json = match.first.value as List<dynamic>;
        return json.map((e) => HtmlParserNode()..jsonNode = e).toList();
      } else {
        return <HtmlParserNode>[];
      }
    }
  }
}

class HtmlParserNode {
  XPathNode<Node>? xpathNode;
  Map<String, dynamic>? jsonNode;
}
