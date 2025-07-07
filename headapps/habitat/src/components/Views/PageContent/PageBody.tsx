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

const PageBody = (props: ComponentProps): JSX.Element => {
  return (
    <>
    <h3 style={{ color: 'red' }}>Page Body</h3>
      <div className="m-b-2">
        <p>The Habitat project - this website - is completely available for you on GitHub, source code and all.</p>
      <p>The full description of the Helix Guidelines are available on http://helix.sitecore.net.</p>
      <p>There are also a number of videos concerning the methodology and it's underlying patterns.</p>
      </div>

    </>
  );
};

export default PageBody;
