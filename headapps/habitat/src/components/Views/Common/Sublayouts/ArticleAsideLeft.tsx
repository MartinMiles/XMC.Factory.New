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

const ArticleAsideLeft = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red', margin: '10px' }}>Article Aside Left</h3>

      <div className="unknown">
        <div className="row">
          <div className="col-lg-4">
            <aside>
              <Placeholder name="col-narrow-1" rendering={props.rendering} />
            </aside>
          </div>
          <div className="col-lg-8">
            <article>
              <Placeholder name="col-wide-1" rendering={props.rendering} />
            </article>
            <div>
              <Placeholder name="section-narrow" rendering={props.rendering} />
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default ArticleAsideLeft;
