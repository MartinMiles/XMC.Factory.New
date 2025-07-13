import { DateField } from '@sitecore-jss/sitecore-jss-nextjs';
import React from 'react';

// NewsDate - Datetime
// NewsTitle - Single-Line Text
// NewsImage - Image
// NewsSummary - Rich Text
// NewsBody - Rich Text

interface ItemProps {
  url: { url: string };
  newsDate: { value: Date };
  newsTitle: { value: string };
}

interface LatestNewsProps {
  params: { [key: string]: string };
  fields: {
    data: {
      search: {
        results: ItemProps[];
      };
    };
  };
}

const LatestNews = (props: LatestNewsProps): JSX.Element => {
  return (
    <>
      <h3 style={{ color: 'red', margin: '10px' }}>Latest News</h3>
      <div className="well ">
        <h5 className="text-uppercase">News</h5>
        <ul className="media-list">
          {/* {props.fields.items.length} */}

          {props.fields.data.search.results.map((item, idx) => (
            <li key={idx} className="media">
              <div className="media-body">
                <DateField field={item.newsDate} />

                <h4 className="media-heading">
                  <a href={item.url.url}>{item.newsTitle.value}</a>
                </h4>
              </div>
            </li>
          ))}
        </ul>
        <a href="http://habitat.dev.local/en/Modules/Feature/News/News" className="btn btn-default">
          Read more
        </a>
      </div>
    </>
  );
};

export default LatestNews;
