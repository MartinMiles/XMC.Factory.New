import { ComponentParams, ComponentRendering } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface ComponentProps {
  rendering: ComponentRendering & { params: ComponentParams };
  params: ComponentParams;
}

const FacebookOpenGraphMetadata = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <meta property="og:title" content="" />
      <meta property="og:image" content="" />
      <meta property="og:description" content="" />
      <meta property="og:url" content="http://habitat.dev.local/en/About Habitat" />
    </>
  );
};

export default FacebookOpenGraphMetadata;
