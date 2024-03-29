# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]


## [0.2.2] - 2024-03-12


### Changed
- `Qwen.text_to_image(text)`，不提供`image_path`时默认为`nil`，此时返回`image_url`


## [0.2.1] - 2024-03-04


### Fixed
- 修复文档错误； 优化文档格式(#8)


## [0.2.0] - 2024-03-03

### Added
- 新增`Qwen.text_to_image`用于通义万相文生图模型的调用
- 新增`sigil_p`用于文生图的字符模版解析


### Changed
- `sigil_l`从`Qwen.Generation`迁移到`Qwen.Sigils`


### Removed
- 删除`Qwen.generation`(原始格式调用文本生成), 仅保留`Qwen.chat`.


### Internal
- 增加CI测试


## [0.1.0] - 2024-02-29

### Added
- 增加通义千问大语言模型[文本生成功能](https://help.aliyun.com/zh/dashscope/developer-reference/quick-start)的封装
