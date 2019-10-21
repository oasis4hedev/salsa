FactoryBot.define do
  factory :salsa_meta_document, class: Document do
    name {"salsa_meta_document_name"}
    lms_course_id {'1234569'}
    organization_id {nil}
    payload {'
      
      <style type="text/css">
      </style>
      
      <!-- spacer for preview modal -->
      <dl data-method="taxonomy" data-target=".outcomes_list">
        <dd data-meta="test_meta">test_meta</dd>
      </dl>
      <div id="spacer">&nbsp;</div>
      <!-- each tab is represented by a section with an ID that identifies it -->
      <section id="information" class="active" style="">
          <!-- content class is the initial content for the tab -->
          <div class="content">
              <header id="title1I">
                      <h1>
                          <div class="editable">meta test document</div>
                          <div class="editable">Course Number | Term/Year</div>
                      </h1>
                      <dl data-method="taxonomy" data-target=".outcomes_list" class="hide">
                        <dd data-meta="test_meta">test_meta</dd>
                      </dl>
              </header>
              <div id="section1I" class="section1" style="">
                  <h2 class="editable">Contact Information</h2>
      
                  <div id="contacts1I" class="contacts" style="">
                      <div class="contact">
                          <h3 class="editable" data-can-delete="true">Contact Title</h3>
                          <div class="editableHtml"><ul class="none"><li>name</li><li>email</li><li>phone</li><li>other1</li><li>other2</li></ul></div>
                      </div>
      
                   </div>
              </div><!-- .section1 -->
      
             <div id="section2I" class="section2 hide" style="">
                  <h2 class="editable">Section 2</h2>
                  <div id="headings2I" class="headings">
                      <div class="details">
                          <div class="description">
                              <h3 class="editable" data-can-delete="true">Heading</h3>
                              <div class="editableHtml">
                                  Text
                              </div>                      
                              <dl data-method="taxonomy" data-target=".outcomes_list" class="hide">
                                <dd data-meta="test_meta">test_meta</dd>
                              </dl>
                          </div>
                      </div>
                  </div>
              </div><!-- .section2-->
      
              <div id="section3I" class="section3 hide">
                  <h2 class="editable">Section 3</h2>
                  <div id="headings3I" class="headings">
                      <div class="details">
                          <div class="description">
                              <h3 class="editable" data-can-delete="true">Heading</h3>
                              <div class="editableHtml">
                                  Text
                              </div>
                          </div>
                      </div>
                  </div>
              </div><!-- .section3-->
      
              <div id="section4I" class="section4 hide" style="">
                  <h2 class="editable">Section 4</h2>
                  <div id="headings4I" class="headings">
                      <div class="details">
                          <div class="description">
                              <h3 class="editable" data-can-delete="true">Heading</h3>
                              <div class="editableHtml">
                                  Text
                              </div>
                          </div>
                      </div>
                  </div>
              </div><!-- .section4-->
      
          </div><!-- .content -->
      
      </section><!-- #information -->
      
      <section id="outcomes" class="" style="">
          <div class="content">
              <div id="section1O" class="section1">
                  <h2 class="editable">Learning Outcomes</h2>
                  <div class="editable" data-can-delete="true">Upon completion of this course you will be able to:</div>
                      <!-- bullets should be visible in this list -->
                      <div id="headings1O" class="headings">
                          <div class="editableHtml">
                              <ul class="outcomes_list">
                                  <li>Outcome text here</li>
                              </ul>
                          </div>
                      </div>
              </div><!-- .section1 -->
      
             <div id="section2O" class="section2 hide">
                  <h2 class="editable">Section 2</h2>
                  <div id="headings2O" class="headings">
                      <div class="details">
                          <div class="description">
                              <h3 class="editable" data-can-delete="true">Heading</h3>
                              <div class="editableHtml">
                                  Text
                              </div>
                          </div>
                      </div>
                  </div>
              </div><!-- .section2-->
      
              <div id="section3O" class="section3 hide">
                  <h2 class="editable">Section 3</h2>
                  <div id="headings3O" class="headings">
                      <div class="details">
                          <div class="description">
                              <h3 class="editable" data-can-delete="true">Heading</h3>
                              <div class="editableHtml">
                                  Text
                              </div>
                          </div>
                      </div>
                  </div>
              </div><!-- .section3-->
      
             <div id="section4O" class="section4 hide">
                  <h2 class="editable">Section 4</h2>
                  <div id="headings4O" class="headings">
                      <div class="details">
                          <div class="description">
                              <h3 class="editable" data-can-delete="true">Heading</h3>
                              <div class="editableHtml">
                                  Text
                              </div>
                          </div>
                      </div>
                  </div>
              </div><!-- .section4-->
      
          </div><!-- .content -->
      
      </section><!-- #outcomes -->
      
      
      <section id="resources" class="" style="">
          <div class="content">
              <div id="section1R" class="section1">
                  <h2 class="editable">Learning Resources</h2>
                  <div id="headings1R" class="headings">
                      <div class="details">
                          <div class="description">
                              <h3 class="editable" data-can-delete="true">Heading</h3>
                              <div class="editableHtml">
                                  Text
                              </div>
                          </div>
                      </div>
                  </div>
              </div><!-- .section1 -->
      
             <div id="section2R" class="section2 hide">
                  <h2 class="editable">Section 2</h2>
                  <div id="headings2R" class="headings">
                      <div class="details">
                          <div class="description">
                              <h3 class="editable" data-can-delete="true">Heading</h3>
                              <div class="editableHtml">
                                  Text
                              </div>
                          </div>
                      </div>
                  </div>
              </div><!-- .section2-->
      
              <div id="section3R" class="section3 hide">
                  <h2 class="editable">Section 3</h2>
                  <div id="headings3R" class="headings">
                      <div class="details">
                          <div class="description">
                              <h3 class="editable" data-can-delete="true">Heading</h3>
                              <div class="editableHtml">
                                  Text
                              </div>
                          </div>
                      </div>
                  </div>
              </div><!-- .section3-->
      
             <div id="section4R" class="section4 hide">
                  <h2 class="editable">Section 4</h2>
                  <div id="headings4R" class="headings">
                      <div class="details">
                          <div class="description">
                              <h3 class="editable" data-can-delete="true">Heading</h3>
                              <div class="editableHtml">
                                  Text
                              </div>
                          </div>
                      </div>
                  </div>
              </div><!-- .section4-->
      
          </div><!-- .content -->
      
      </section><!-- #resources -->
      
      <section id="activities" class="" style="">
          <div class="content">
      
              <div id="section1A" class="section1">
                  <h2 class="editable">Learning Activities</h2>
                  <div id="headings1A" class="headings">
                      <div class="details">
                          <div class="description">
                              <h3 class="editable" data-can-delete="true">Heading</h3>
                              <div class="editableHtml">
                                  Text
                              </div>
                          </div>
                      </div>
                  </div>
              </div><!-- .section1 -->
      
             <div id="section2A" class="section2 hide">
                  <h2 class="editable">Section 2</h2>
                  <div id="headings2A" class="headings">
                      <div class="details">
                          <div class="description">
                              <h3 class="editable" data-can-delete="true">Heading</h3>
                              <div class="editableHtml">
                                  Text
                              </div>
                          </div>
                      </div>
                  </div>
              </div><!-- .section2-->
      
              <div id="section3A" class="section3 hide">
                  <h2 class="editable">Section 3</h2>
                  <div id="headings3A" class="headings">
                      <div class="details">
                          <div class="description">
                              <h3 class="editable" data-can-delete="true">Heading</h3>
                              <div class="editableHtml">
                                  Text
                              </div>
                          </div>
                      </div>
                  </div>
              </div><!-- .section3-->
      
             <div id="section4A" class="section4 hide">
                  <h2 class="editable">Section 4</h2>
                  <div id="headings4A" class="headings">
                      <div class="details">
                          <div class="description">
                              <h3 class="editable" data-can-delete="true">Heading</h3>
                              <div class="editableHtml">
                                  Text
                              </div>
                          </div>
                      </div>
                  </div>
              </div><!-- .section4-->
      
          </div><!-- .content -->
      
      </section><!-- #activities -->
      
      <section id="policies" class="" style="">
          <div class="content">
      
              <div id="section1P" class="section1">
                  <h2 class="editable">Policies</h2>
                  <div id="headings1P" class="headings">
                      <div class="details">
                          <div class="description">
                              <h3 class="editable" data-can-delete="true">Heading</h3>
                              <div class="editableHtml">
                                  Text
                              </div>
                          </div>
                      </div>
                  </div>
              </div><!-- .section1 -->
      
             <div id="section2P" class="section2 hide">
                  <h2 class="editable">Section 2</h2>
                  <div id="headings2P" class="headings">
                      <div class="details">
                          <div class="description">
                              <h3 class="editable" data-can-delete="true">Heading</h3>
                              <div class="editableHtml">
                                  Text
                              </div>
                          </div>
                      </div>
                  </div>
              </div><!-- .section2-->
      
              <div id="section3P" class="section3 hide">
                  <h2 class="editable">Section 3</h2>
                  <div id="headings3P" class="headings">
                      <div class="details">
                          <div class="description">
                              <h3 class="editable" data-can-delete="true">Heading</h3>
                              <div class="editableHtml">
                                  Text
                              </div>
                          </div>
                      </div>
                  </div>
              </div><!-- .section3-->
      
             <div id="section4P" class="section4 hide">
                  <h2 class="editable">Section 4</h2>
                  <div id="headings4P" class="headings">
                      <div class="details">
                          <div class="description">
                              <h3 class="editable" data-can-delete="true">Heading</h3>
                              <div class="editableHtml">
                                  Text
                              </div>
                          </div>
                      </div>
                  </div>
              </div><!-- .section4-->
      
          </div><!-- .content -->
      </section><!-- #policies -->
      
      
      
      <section id="grades" class="" style="">
          <div class="content">
              <div id="section_break_P" class="section_break_P hide">
                  <div class="editableHtml page_break">
                      <div align="center">
                          ----Please see next page for Grades information----
                      </div>
                  </div>
              </div><!-- .section5-->
      
              <div id="section1G" class="section1">
                 <h2 class="editable">Grades</h2>
                  <div class="details">
                      <div class="description">
                          <div>
                              <table id="grade_components" class="components" border="1">
                                  <caption class="grade editable">Your grade will be based on the following:</caption>
                                  <thead>
                                      <tr><th class="editable" scope="col">Items</th><th scope="col">Points</th></tr>
                                  </thead>
                                  <tfoot>
                                      <tr class="total nodrag"><th scope="row" class="right">Total Points</th><td class="right">-</td></tr>
                                  </tfoot>
                                  <tbody>
                                          <tr id="1.1"><th class="editable" scope="row">Item</th><td class="editable right">-</td></tr>
                                          <tr id="1.2"><th class="editable" scope="row">Item</th><td class="editable right">-</td></tr>
                                  </tbody>
                              </table>
                          <div id="tableText1G" class="tableText">
                              <div class="editableHtml hide">Text</div>
                          </div>
                          </div>
                      </div>
                  </div>
              </div><!-- .section1 -->
      
              <div id="section2G" class="section2 hide">
                  <div class="details">
                      <div class="description">
                          <div>
                              <table id="extra_credit" class="components" border="1">
                                  <caption class="grade editable">You will have the opportunity to earn Extra Credit:</caption>
                                  <thead>
                                      <tr><th class="editable" scope="col">Items</th><th scope="col">Points</th></tr>
                                  </thead>
                                  <tfoot>
                                      <tr class="total nodrag"><th scope="row" class="right">Total Extra Credit Points</th><td class="right">-</td></tr>
                                  </tfoot>
                                  <tbody>
                                      <tr id="2.1"><th class="editable" scope="row">Item</th><td class="editable right">-</td></tr>
                                  </tbody>
                              </table>
                          <div id="tableText2G" class="tableText">
                              <div class="editableHtml hide">Text</div>
                          </div>
                          </div>
                      </div>
                  </div>
              </div><!-- .section2 -->
              <div id="section3G" class="section3">
                  <div class="details">
                      <div class="description">
                          <div>
                              <table id="grade_scale" class="components" border="1">
                                      <caption class="grade editable">Your grade will be calculated with this scale:</caption>
                                      <thead>
                                          <tr><th scope="col">Grade</th><th scope="col">Percentage</th><th scope="col">Points</th></tr>
                                      </thead>
                                      <tbody class="center">
                                          <tr>
                                              <th scope="row">A</th>
                                              <td>
                                                  <span class="editable minRange">93</span>
                                                  -
                                                  <span class="maxRange">100</span>
                                              </td>
                                              <td>-</td>
                                          </tr>
      
                                          <tr class="even">
                                              <th scope="row">A-</th>
                                              <td>
                                                  <span class="editable minRange">90</span>
                                                  -
                                                  <span class="maxRange">92</span>
                                              </td>
                                              <td>-</td>
                                          </tr>
      
                                          <tr>
                                              <th scope="row">B+</th>
                                              <td>
                                                  <span class="editable minRange">87</span>
                                                  -
                                                  <span class="maxRange">89</span>
                                              </td>
                                              <td>-</td>
                                          </tr>
      
                                          <tr class="even">
                                              <th scope="row">B</th>
                                              <td>
                                                  <span class="editable minRange">83</span>
                                                  -
                                                  <span class="maxRange">86</span>
                                              </td>
                                              <td>-</td>
                                          </tr>
      
                                          <tr>
                                              <th scope="row">B-</th>
                                              <td>
                                                  <span class="editable minRange">80</span>
                                                  -
                                                  <span class="maxRange">82</span>
                                              </td>
                                              <td>-</td>
                                          </tr>
      
                                          <tr class="even">
                                              <th scope="row">C+</th>
                                              <td>
                                                  <span class="editable minRange">77</span>
                                                  -
                                                  <span class="maxRange">79</span>
                                              </td>
                                              <td>-</td>
                                          </tr>
      
                                          <tr>
                                              <th scope="row">C</th>
                                              <td>
                                                  <span class="editable minRange">73</span>
                                                  -
                                                  <span class="maxRange">76</span>
                                              </td>
                                              <td>-</td>
                                          </tr>
      
                                          <tr class="even">
                                              <th scope="row">C-</th>
                                              <td>
                                                  <span class="editable minRange">70</span>
                                                  -
                                                  <span class="maxRange">72</span>
                                              </td>
                                              <td>-</td>
                                          </tr>
      
                                          <tr>
                                              <th scope="row">D+</th>
                                              <td>
                                                  <span class="editable minRange">67</span>
                                                  -
                                                  <span class="maxRange">69</span>
                                              </td>
                                              <td>-</td>
                                          </tr>
      
                                          <tr class="even">
                                              <th scope="row">D</th>
                                              <td>
                                                  <span class="editable minRange">60</span>
                                                  -
                                                  <span class="maxRange">66</span>
                                              </td>
                                              <td>-</td>
                                          </tr>
      
                                          <tr>
                                              <th scope="row">F</th>
                                              <td>
                                                  <span class="minRange">0</span>
                                                  -
                                                  <span class="maxRange">59</span>
                                              </td>
                                              <td>-</td>
                                          </tr>
                                      </tbody>
                              </table>
                          </div>
                      </div>
                  </div>
              </div><!-- .section3 -->
          </div><!-- .content -->
      
      </section><!-- #grades -->
      
      <section id="schedule" class="" style="">
          <div class="content">
              <div id="section1S" class="section1 hide">
                  <div class="page_break editableHtml">
                      <div align="center">
                          ----Please see next page for Schedule information----
                      </div>
                  </div>
              </div><!-- .section1S-->
      
              <h2 class="editable">Course Schedule</h2>
              <div id="section2S" class="section2">
                  <div class="details">
                      <div class="description">
                          <div>
                              <table id="table1" class="schedule" border="1">
                                  <caption class="editable">Table 1 Caption</caption>
                                  <thead>
                                      <tr>
                                          <th id="col2S-left" class="col-left15 editable" scope="col">Module</th>
                                          <th id="col2S-middle" class="col-middle35 editable" scope="col">Topic</th>
                                          <th id="col2S-right" class="col-right50 editable" scope="col">Assignment</th>
                                      </tr>
                                  </thead>
                                  <tbody>
                                      <tr>
                                          <th header="col2S-left" class="editable center" scope="row">#</th>
                                          <td header="col2S-middle" class="editable left">Text</td>
                                          <td header="col2S-right" class="editable left">Text</td>
                                      </tr>
                                  </tbody>
                              </table>
                          <div id="tableText2S" class="tableText">
                              <div class="editableHtml hide">Text</div>
                          </div>
                          </div>
                      </div>
                  </div>
              </div><!-- #table1 -->
      
              <div id="section3S" class="section3 hide">
                  <div class="details">
                      <div class="description">
                          <div>
                              <table id="table2" class="schedule" border="1">
                                  <caption class="editable">Table 2 Caption</caption>
                                  <thead>
                                      <tr>
                                          <th id="col3S-left" class="col-left15 editable" scope="col">Module</th>
                                          <th id="col3S-middle" class="col-middle35 editable" scope="col">Topic</th>
                                          <th id="col3S-right" class="col-right50 editable" scope="col">Assignment</th>
                                      </tr>
                                  </thead>
                                  <tbody>
                                      <tr>
                                          <th header="col3S-left" class="editable center" scope="row">#</th>
                                          <td header="col3S-middle" class="editable left">Text</td>
                                          <td header="col3S-right" class="editable left">Text</td>
                                      </tr>
                                  </tbody>
                              </table>
                          <div id="tableText3S" class="tableText">
                              <div class="editableHtml hide">Text</div>
                          </div>
                          </div>
                      </div>
                  </div>
              </div><!-- #table2 -->
      
              <div id="section4S" class="section4 hide">
                  <div class="details">
                      <div class="description">
                          <div>
                              <table id="table3" class="schedule" border="1">
                                  <caption class="editable">Table 3 Caption</caption>
                                  <thead>
                                      <tr>
                                          <th id="col4S-left" class="col-left15 editable" scope="col">Module</th>
                                          <th id="col4S-middle" class="col-middle35 editable" scope="col">Topic</th>
                                          <th id="col4S-right" class="col-right50 editable" scope="col">Assignment</th>
                                      </tr>
                                  </thead>
                                  <tbody>
                                      <tr>
                                          <th header="col4S-left" class="editable center" scope="row">#</th>
                                          <td header="col4S-middle" class="editable left">Text</td>
                                          <td header="col4S-right" class="editable left">Text</td>
                                      </tr>
                                  </tbody>
                              </table>
                          <div id="tableText4S" class="tableText">
                              <div class="editableHtml hide">Text</div>
                          </div>
                          </div>
                      </div>
                  </div>
              </div><!-- #table3 -->
          </div><!-- .content -->
      
      </section><!-- #schedule -->
      '}
  end
end