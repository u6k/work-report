# 活動レポート _(work-report)_

[![Travis](https://img.shields.io/travis/u6k/work-report.svg)](https://travis-ci.org/u6k/work-report) [![license](https://img.shields.io/github/license/u6k/work-report.svg)](https://github.com/u6k/work-report/blob/master/LICENSE) [![GitHub release](https://img.shields.io/github/release/u6k/work-report.svg)](https://github.com/u6k/work-report/releases) [![Website](https://img.shields.io/website-up-down-green-red/https/redmine.u6k.me%2Fprojects%2Fwork-report.svg?label=u6k.Redmine)](https://redmine.u6k.me/projects/work-report) [![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

> 個人的な活動ログをレポートする

__Table of Contents__

- [Background](#Background)
- [Install](#Install)
- [Usage](#Usage)
- [Other](#Other)
- [API](#API)
- [Maintainer](#Maintainer)
- [Contributing](#Contributing)
- [License](#License)

## Background

ブログに週次・月次で活動ログを記載していますが、手作業だと負担が大きいです。活動ログを自動的に収集、生成したいと思います。

- やりたいこと
    - GitHubの活動数をレポートしたい
    - u6k.Redmineの活動数をレポートしたい
    - Twitterのツイート数をレポートしたい
        - 主要ツイートには所感を記述したい
    - Pocketの増加数/消化数をレポートしたい
    - 他、習慣の達成状況をレポートしたい
- やらなくても良い
    - ブログ記事を生成するが、自動的なリリースはしない
        - 所感を記述したり、内容を精査してからリリースしたいため

## Install

```
gem 'work-report', :git => 'git://github.com/u6k/work-report.git'
```

## Usage

```
$ work-report help
Commands:
  work-report github_commits      # Output github commits to csv
  work-report github_releases     # Output github releases to csv
  work-report help [COMMAND]      # Describe available commands or one specific command
  work-report redmine_activities  # Output redmine activities to csv
```

## Other

最新の情報は、 [Wiki - work-report - u6k.Redmine](https://redmine.u6k.me/projects/work-report/wiki) を参照してください。

- [コンテキスト・モデル](https://redmine.u6k.me/projects/work-report/wiki/%E3%82%B3%E3%83%B3%E3%83%86%E3%82%AD%E3%82%B9%E3%83%88%E3%83%BB%E3%83%A2%E3%83%87%E3%83%AB)
- [要求・要件](https://redmine.u6k.me/projects/work-report/wiki/%E8%A6%81%E6%B1%82%E3%83%BB%E8%A6%81%E4%BB%B6)
- [業務フロー](https://redmine.u6k.me/projects/work-report/wiki/%E6%A5%AD%E5%8B%99%E3%83%95%E3%83%AD%E3%83%BC)
- [サンプル](https://redmine.u6k.me/projects/work-report/wiki/%E3%82%B5%E3%83%B3%E3%83%97%E3%83%AB)
- [ビルド手順](https://redmine.u6k.me/projects/work-report/wiki/%E3%83%93%E3%83%AB%E3%83%89%E6%89%8B%E9%A0%86)
- [リリース手順](https://redmine.u6k.me/projects/work-report/wiki/%E3%83%AA%E3%83%AA%E3%83%BC%E3%82%B9%E6%89%8B%E9%A0%86)

## API

[APIリファレンス](https://u6k.github.io/work-report/) を参照してください。

## Maintainer

- u6k
  - [Twitter](https://twitter.com/u6k_yu1)
  - [GitHub](https://github.com/u6k)
  - [Blog](https://blog.u6k.me/)

## Contributing

このプロジェクトにご興味を持っていただき、ありがとうございます。素晴らしいアイデアをお持ちであれば、[work-report - u6k.Redmine](https://redmine.u6k.me/projects/work-report)にチケットを作成していただけると幸いです。

当プロジェクトは、 [Contributor Covenant](https://www.contributor-covenant.org/version/1/4/code-of-conduct) に準拠します。

## License

[MIT License](https://github.com/u6k/work-report/blob/master/LICENSE)
