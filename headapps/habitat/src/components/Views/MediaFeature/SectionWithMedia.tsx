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

const PageHeaderwithMedia = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3>Section With Media</h3>

      <section className="section section-full @Model.CssClass">
        <Placeholder name="section" rendering={props.rendering} />
      </section>
    </>
  );
};

export default PageHeaderwithMedia;
