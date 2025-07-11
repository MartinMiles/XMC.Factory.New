import { DictionaryPhrases, Image, RichText } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';
import { useI18n } from 'next-localization';

export function useTranslations() {
  const i18n = useI18n();
  return {
    readLabel: i18n?.t('read'),
  };
}

type PageTeaserProps = {
  dictionary: DictionaryPhrases;
  params: { [key: string]: string };
  fields: {
    data: {
      datasource: {
        Title: { value: string };
        Summary: { value: string };
        Image: {
          jsonValue: {
            src: string;
            alt: string;
            width: number;
            height: number;
          };
        };
        url: { url: string };
      };
    };
  };
};

const PageTeaser = (props: PageTeaserProps): JSX.Element => {
  const model = props.fields.data.datasource;
  const translations = useTranslations();

  return (
    <>
      <h3 style={{ color: 'red', margin: '5px' }}>Page Teaser</h3>
      <div className="thumbnail">
        <a href={model.url.url} target="_blank" rel="noopener noreferrer">
          <Image
            field={model.Image.jsonValue}
            height="500"
            width="500"
            imageParams={{ mw: 500, mh: 500 }}
          />
        </a>
        <div className="caption">
          <h3 className="teaser-heading">
            <RichText field={model.Title} />
          </h3>
          <p>
            <RichText field={model.Summary} />
          </p>
          <a href={model.url.url} className="btn btn-default">
            {translations.readLabel}
          </a>
        </div>
      </div>
    </>
  );
};

export default PageTeaser;
