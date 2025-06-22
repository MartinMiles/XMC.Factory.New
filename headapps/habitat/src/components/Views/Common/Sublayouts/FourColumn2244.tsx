import {
  ComponentParams,
  ComponentRendering,
  Placeholder,
} from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface ComponentProps {
  rendering: ComponentRendering & { params: ComponentParams };
  params: ComponentParams;
}

const FourColumn2244 = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red' }}>Four Column 2-2-4-4</h3>
      <div className="container">
        <div className="row">
          <div className="col-md-2 col-sm-6">
            <Placeholder name="col-narrow-1" rendering={props.rendering} />
            {/* <ul className="nav nav-stacked">
              <li>
                <a href="http://community.sitecore.net" target="_blank" title="Community">
                  <span>Community</span>
                </a>
              </li>
              <li>
                <a href="https://doc.sitecore.net" target="_blank" title="Documentation">
                  <span>Documentation</span>
                </a>
              </li>
              <li>
                <a href="http://kb.sitecore.net" target="_blank" title="Knowledge Base">
                  <span>Knowledge Base</span>
                </a>
              </li>
              <li>
                <a href="http://spn.sitecore.net" target="_blank" title="Partner Network">
                  <span>Partner Network</span>
                </a>
              </li>
            </ul> */}
          </div>
          <div className="col-md-2 col-sm-6">
            <Placeholder name="col-narrow-2" rendering={props.rendering} />
            {/* <ul className="nav nav-stacked">
              <li>
                <a
                  href="https://www.sitecore.com/company/blog"
                  target="_blank"
                  title="Sitecore Blog"
                >
                  <span>Sitecore Blog</span>
                </a>
              </li>
              <li>
                <a
                  href="https://community.sitecore.net/technical_blogs/"
                  target="_blank"
                  title="Technical Blog"
                >
                  <span>Technical Blog</span>
                </a>
              </li>
              <li>
                <a href="https://sitecore.stackexchange.com" target="_blank" title="Stackexchange">
                  <span>Stackexchange</span>
                </a>
              </li>
              <li className="divider"></li>
              <li>
                <a
                  href="https://www.sitecore.com/company/contact-us"
                  target="_blank"
                  title="Contact Sitecore"
                >
                  <span>Contact Sitecore</span>
                </a>
              </li>
            </ul> */}
          </div>
          <div className="col-md-4 col-sm-6">
            <Placeholder name="col-narrow-3" rendering={props.rendering} />
            {/* <div className="well ">
              <h4>About Habitat</h4>
              <p>
                Habitat sites are demonstration sites for the Sitecore® Experience Platform™.
                <br />
                The sites demonstrate the full set of capabilities and potential of the platform
                through a number of both technical and business scenarios.
              </p>
              <a
                className="btn btn-default"
                rel="noopener noreferrer"
                href="http://github.com/sitecore/habitat"
                target="_blank"
              >
                Example available on GitHub
              </a>
            </div> */}
          </div>
          <div className="col-md-4 col-sm-6">
            <Placeholder name="col-narrow-4" rendering={props.rendering} />
            {/* <div className="well ">
              <h4>Contact information</h4>

              <address>
                <p>
                  <strong>Sitecore Corporation</strong>
                  <br />
                  101 California Street <br />
                  Suite 1600 <br />
                  San Francisco, CA 94111
                  <br />
                  USA
                </p>
                <p>
                  <br />
                  <i className="fa fa-phone"></i> +1 415 380 0600 <br />
                  <i className="fa fa-envelope"></i>{' '}
                  <a href="mailto:sales@sitecore.net">sales@sitecore.net</a>{' '}
                </p>
              </address>
            </div> */}
          </div>
        </div>
      </div>
    </>
  );
};

export default FourColumn2244;
