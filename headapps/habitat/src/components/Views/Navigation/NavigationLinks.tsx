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

const NavigationLinks = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red' }}>Navigation Links</h3>
      <ul className="nav nav-stacked">
        <li>
          <a href="https://www.sitecore.com/company/blog" target="_blank" title="Sitecore Blog">
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
      </ul>
    </>
  );
};

export default NavigationLinks;
