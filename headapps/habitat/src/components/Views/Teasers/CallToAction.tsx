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

const CalltoAction = (props: ComponentProps): JSX.Element => {
  return (
    <>
      <div
        className="jumbotron text-center bg-media"
        style={{
          backgroundImage:
            "url('/-/media/Habitat/Images/Wide/Habitat-038-wide.jpg?h=660&w=1920&hash=58403D343E52524B5C12E05D7D58E604')",
        }}
      >
        <span className="label">Want More?</span>
        <h2>Check out the Sitecore Habitat Demos</h2>
        <p className="">
          Just as this Habitat site, there are additional Sitecore demo sites available on github.
          <br />
          Check out for example the Legal Services, Financial Services or Utilities sites.
        </p>
        <a
          className="btn btn-primary btn-lg"
          rel="noopener noreferrer"
          href="https://github.com/sitecore/sitecore.demo"
          target="_blank"
        >
          Sitecore Demos on GitHub
        </a>
      </div>
    </>
  );
};

export default CalltoAction;
