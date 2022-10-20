import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';

import 'package:html_parser/html_parser.dart';
import 'package:xpath_selector/xpath_selector.dart';

void main() {
  test('parse and parseNodes works well', () {
    const String htmlString = '''
      <html lang="en">
      <body>
      <div><a href='https://github.com/simonkimi'>author</a></div>
      <div class="head">div head</div>
      <div class="container">
          <table>
              <tbody>
                <tr>
                    <td id="td1" class="first1">1</td>
                    <td id="td2" class="first1">2</td>
                    <td id="td3" class="first2">3</td>
                    <td id="td4" class="first2 form">4</td>

                    <td id="td5" class="second1">one</td>
                    <td id="td6" class="second1">two</td>
                    <td id="td7" class="second2">three</td>
                    <td id="td8" class="second2">four</td>
                </tr>
              </tbody>
          </table>
      </div>
      <div class="end">end</div>
      </body>
      </html>
      ''';
    final parser = HtmlParser();
    final node = parser.query(htmlString);
    expect(parser.parse(node, '//div/a@text'), 'author');
    expect(
        parser.parse(node,
            '//div/a/@href|function:replace(https://,)|function:substring(0,10)'),
        'github.com');
    expect(parser.parseNodes(node, '//tr/td|function:sublist(0,2)').runtimeType,
        List<XPathNode<Node>>);
    expect(parser.parseNodes(node, '//tr/td|function:sublist(0,2)').length, 2);
  });
}
