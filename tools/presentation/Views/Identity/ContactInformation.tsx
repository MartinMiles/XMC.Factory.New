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

const ContactInformation = (props: ComponentProps): JSX.Element => {
  return (
    <>
      
      
      
      <div className="well ">
        <h4>Contact information</h4>
      
        <address>
          <p>
              <strong>Sitecore Corporation</strong>
            <br/>
            101 California Street <br/>Suite 1600 <br/>San Francisco, CA 94111<br/>USA
          </p>
          <p>
              <br />
              <i className="fa fa-phone"></i> +1 415 380 0600              <br />
              <i className="fa fa-envelope"></i> <a href="mailto:sales@sitecore.net">sales@sitecore.net</a>    </p>
        </address>
      </div>
      
      
    </>
  );
};

export default ContactInformation;
