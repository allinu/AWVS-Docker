package main

import (
	"flag"
	"fmt"
	htmltomd "github.com/XRSec/HTML-TO-MARKDOWN/src"
	"github.com/anaskhan96/soup"
	"io/ioutil"
	"os"
	"regexp"
	"strings"
)

var (
	last           string
	latest         string
	packageVersion = flag.String("v", "old", "指定版本号 获取最新的 README 文档 例如: -v 15.0.221007170")
)

func init() {
	flag.Parse()
	if *packageVersion == "old" {
		fmt.Println("请指定版本号")
		os.Exit(1)
	}

	res, err := ioutil.ReadFile("LAST_VERSION")
	if err != nil {
		fmt.Printf("读取文件失败, Error: %v", err)
		os.Exit(1)
	}

	// 去除 换行符 和 空格
	if strings.Replace(strings.Replace(string(res), " ", "", -1), "\n", "", -1) == *packageVersion {
		fmt.Println("版本号未更新")
		os.Exit(1)
	}
}

func main() {
	flag.Parse()
	genContent(*packageVersion) // get latest last res

	// 读取模板
	// read head
	head := strings.Replace(readFile("README_HEAD"), "LatestVersion", *packageVersion, -1)

	latest = htmltomd.Convert(latest, "", false)

	use := readFile("README_USE")

	last = htmltomd.Convert(last, "", false)

	footer := readFile("README_FOOTER")

	if err := ioutil.WriteFile("../../README.md", []byte(head+latest+use+last+footer), 0666); err != nil {
		fmt.Printf("写入文件失败, Error: %v", err)
		return
	}
	if err := ioutil.WriteFile("LAST_VERSION", []byte(*packageVersion), 0666); err != nil {
		fmt.Printf("写入文件失败, Error: %v", err)
		return
	}
}

func genContent(version string) {
	res, err := soup.Get("https://www.acunetix.com/changelogs/acunetix-premium/")
	if err != nil {
		fmt.Printf("获取页面失败, Error: %v", err)
		return
	}

	bytes, err := ioutil.ReadAll(strings.NewReader(res))
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	doc := soup.HTMLParse(string(bytes))
	resV1 := doc.FindAll("article")

	for i := 0; i < len(resV1); i++ {
		title := getTitle(resV1[i].Find("div", "class", "article-summary").Text())
		if strings.Contains(title, version) {
			latest = title + resV1[i].Find("div", "class", "article-full-content").HTML()
			if i+1 < len(resV1) {
				var re = regexp.MustCompile(`(\d{1,6})\.(\d{1,6})\.(\d{1,10})`)
				oldTitle := getTitle(resV1[i+1].Find("div", "class", "article-summary").Text())
				if len(re.FindStringIndex(oldTitle)) > 0 {
					oldTitle = re.FindString(oldTitle)
				}
				oldTitle = "<h2>Previous " + oldTitle + "</h2>"
				last = oldTitle + resV1[i+1].Find("div", "class", "article-full-content").HTML()
			}
			break
		}
	}
}

func getTitle(title string) string {
	title = strings.Replace(title, "\n", "", -1)
	title = strings.ReplaceAll(title, "\t", "")
	title = strings.ReplaceAll(title, "  ", "")
	title = "<h2>" + title + "</h2>"
	return title
}

func readFile(filename string) string {
	bytes, err := ioutil.ReadFile(filename)
	if err != nil {
		fmt.Printf("未找到文件: %v", filename)
		return ""
	}
	return string(bytes)
}
