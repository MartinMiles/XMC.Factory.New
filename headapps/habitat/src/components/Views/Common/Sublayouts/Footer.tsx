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

const Footer = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red' }}>Footer</h3>
      <Placeholder name="section" rendering={props.rendering} />

      <div className="footer-bottom text-center">
        <div className="container">
          <div className="row">
            <div className="col-md-12">
              <Placeholder name="postfooter" rendering={props.rendering} />
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default Footer;
