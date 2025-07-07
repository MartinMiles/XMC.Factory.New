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

const HTMLMetadata = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <title>About Habitat - Habitat Sitecore Example Site</title>
    </>
  );
};

export default HTMLMetadata;
