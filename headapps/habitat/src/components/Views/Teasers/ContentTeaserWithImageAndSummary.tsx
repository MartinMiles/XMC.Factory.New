import { ImageField, LinkFieldValue, Text, Image, Link } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

interface Fields {
  TeaserTitle: { value: string };
  TeaserSummary: { value: string };
  TeaserImage: { value: ImageField };
  TeaserLink: { value: LinkFieldValue };
}

type ContentTeaserWithImageAndSummaryProps = {
  params: { [key: string]: string };
  fields: Fields;
};

const ContentTeaserWithImageAndSummary = (
  props: ContentTeaserWithImageAndSummaryProps
): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red', margin: '10px' }}>Content Teaser With Image And Summary</h3>

      <div className="thumbnail  m-b-1">
        <header className="thumbnail-header">
          <h3>
            <Text field={props.fields.TeaserTitle} />
          </h3>
        </header>
        <div>
          <a href="http://www.amazon.com/Agile-Principles-Patterns-Practices-C/dp/0131857258">
            <Image field={props.fields.TeaserImage} />
          </a>
        </div>
        <div className="caption">
          <p>
            <Text field={props.fields.TeaserSummary} />
          </p>
          <Link field={props.fields.TeaserLink} />
        </div>
      </div>
    </>
  );
};

export default ContentTeaserWithImageAndSummary;
