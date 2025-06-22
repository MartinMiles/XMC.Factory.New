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

const SiteMenu = (props: ComponentProps): JSX.Element => {
  return <>
      <h3>Site Menu</h3>
    </>;
};

export default SiteMenu;
