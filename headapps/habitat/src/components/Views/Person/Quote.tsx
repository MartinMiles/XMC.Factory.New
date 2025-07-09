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

const Quote = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red', margin: '10px' }}>Quote</h3>
      <blockquote className="blockquote-center ">
        <header>
          <img
            src="/-/media/Habitat/Images/Content/Anders-Laub-Christoffersen.png?h=119&amp;mh=150&amp;w=157&amp;hash=A5FC02CF7D1DB385E45A3EC53EF77CFF"
            className="img-responsive"
            alt="Anders Laub Christoffersen"
            width="157"
            height="119"
            DisableWebEdit="False"
          />
          <p>Anders Laub Christoffersen</p>
          <p>Sitecore MVP</p>
        </header>
        <p>
          [Habitat...] is nothing less than groundbreaking, it is a real revolution in the way that Sitecore teaches developers to work with their product.
        </p>
      </blockquote>
    </>
  );
};

export default Quote;
