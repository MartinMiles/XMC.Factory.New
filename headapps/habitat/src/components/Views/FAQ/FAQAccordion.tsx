import { ComponentParams, ComponentRendering } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface ComponentProps {
  rendering: ComponentRendering & { params: ComponentParams };
  params: ComponentParams;
}

const FAQAccordion = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red', margin: '10px' }}>FAQ Accordion</h3>

      <div className="panel-group" id="accordion" role="tablist" aria-multiselectable="true">
        <div className="panel panel-default">
          <div className="panel-heading" role="tab" id="headingcollapse0">
            <div className="panel-title">
              <a
                role="button"
                className="accordion-toggle"
                data-toggle="collapse"
                data-parent="#accordion"
                href="#60749ae5-2f4c-428a-8120-fcfaca254c61"
              >
                <span className="glyphicon glyphicon-search" aria-hidden="true"></span>
                What is Habitat?
              </a>
            </div>
          </div>
          <div
            id="60749ae5-2f4c-428a-8120-fcfaca254c61"
            className="panel-collapse collapse"
            role="tabpanel"
            aria-labelledby="headingcollapse0"
          >
            <div className="panel-body">
              <p style={{ color: '#333333', marginBottom: 16 }}>
                Habitat is a Sitecore solution example built on a modular architecture. The
                architecture and methodology focuses on:
              </p>
              <ul style={{ color: '#333333', marginBottom: 16, padding: '0px 0px 0px 2em' }}>
                <li>
                  Simplicity -&nbsp;<em>A consistent and discoverable architecture</em>
                </li>
                <li>
                  Flexibility -&nbsp;<em>Change and add quickly and without worry</em>
                </li>
                <li>
                  Extensibility -&nbsp;<em>Simply add new features without steep learning curve</em>
                </li>
              </ul>
              <p style={{ color: '#333333' }}>
                For more information, please check out the&nbsp;
                <a
                  href="https://github.com/Sitecore/Habitat/wiki"
                  style={{ color: '#4078c0', textDecoration: 'none' }}
                >
                  Habitat Wiki
                </a>
              </p>
            </div>
          </div>
        </div>

        <div className="panel panel-default">
          <div className="panel-heading" role="tab" id="headingcollapse0">
            <div className="panel-title">
              <a
                role="button"
                className="accordion-toggle"
                data-toggle="collapse"
                data-parent="#accordion"
                href="#a4005469-fc8e-4958-bc2c-182a40a61b0c"
              >
                <span className="glyphicon glyphicon-search" aria-hidden="true"></span>
                What does FAQ feature do?
              </a>
            </div>
          </div>
          <div
            id="a4005469-fc8e-4958-bc2c-182a40a61b0c"
            className="panel-collapse collapse"
            role="tabpanel"
            aria-labelledby="headingcollapse0"
          >
            <div className="panel-body">
              <span style={{ backgroundColor: '#ffffff' }}>
                FAQ feature provides component to display QA list.
              </span>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default FAQAccordion;
