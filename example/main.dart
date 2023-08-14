import 'package:html_parser_plus/html_parser_plus.dart';

void main() {
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
  final node = parser.parse(htmlString);
  parser.query(node, '//div/a@text');
  parser.query(node,
      '//div/a/@href|function:replace(https://,)|function:substring(0,10)');
  parser.queryNodes(node, '//tr/td|function:sublist(0,2)');
}
