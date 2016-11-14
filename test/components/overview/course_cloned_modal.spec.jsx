import '../../testHelper';
import React from 'react';
import ReactDOM from 'react-dom';
import ReactTestUtils from 'react-addons-test-utils';
import CourseClonedModal from '../../../app/assets/javascripts/components/overview/course_cloned_modal.jsx';

describe('CourseClonedModal', () => {
  let course = {
    slug: 'foo/bar_(baz)',
    school: 'foo',
    term: 'baz',
    title: 'bar',
    expected_students: 0
  };

  it('renders a Modal', () => {
    const TestModal = ReactTestUtils.renderIntoDocument(
      <CourseClonedModal
        course={course}
      />
    );

    const renderedModal = ReactTestUtils.findRenderedDOMComponentWithClass(TestModal, 'cloned-course');
    expect(renderedModal).not.to.be.empty;
    TestModal.setState({ error_message: null });
    const warnings = ReactTestUtils.scryRenderedDOMComponentsWithClass(TestModal, 'warning');
    return expect(warnings).to.be.empty;
  });

  return it('renders an error message if state includes one', () => {
    const TestModal = ReactTestUtils.renderIntoDocument(
      <CourseClonedModal
        course={course}
      />
    );
    TestModal.setState({ error_message: 'test error message' });

    const warnings = ReactTestUtils.scryRenderedDOMComponentsWithClass(TestModal, 'warning');
    expect(warnings).not.to.be.empty;
    return expect(ReactDOM.findDOMNode(warnings[0]).textContent).to.eq('test error message');
  });
});
