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

const Copyright = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red' }}>Copyright</h3>
      <small className="copyright">
        <p>
          © Copyright 2018,{' '}
          <a href="http://sitecore.net" target="_blank" title="Opens in a new window">
            Sitecore
          </a>
          . All Rights Reserved
          <br />
          <small>
            &ldquo;Habitat&rdquo; as used here is for demonstration purposes only and to represent
            the software and services provided by Sitecore further described at www.sitecore.net.
          </small>
        </p>

        <p>
          <small>
            The Habitat demonstration site is provided for example/reference purposes only. It is
            not supported by Sitecore and should not be used as a starter kit.
          </small>
        </p>
      </small>
    </>
  );
};

export default Copyright;
