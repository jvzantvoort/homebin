//          FILE:  vimtmplrc
//
//         USAGE:  vimtmplrc
//
//   DESCRIPTION:  $description
//
//       OPTIONS:  ---
//  REQUIREMENTS:  ---
//          BUGS:  ---
//         NOTES:  ---
//        AUTHOR:  John van Zantvoort (jvzantvoort), john@vanzantvoort.org
//       COMPANY:  JDC
//       CREATED:  10-Oct-2018
//
// Copyright (C) 2018 John van Zantvoort
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
package main

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"strings"

	"github.com/go-ini/ini"
)

const configfilename string = ".vimtmplrc"

type UserConfig struct {
	mailaddress string
	company     string
}

func (uc UserConfig) UserHomeDir() string {
	if runtime.GOOS == "windows" {
		home := os.Getenv("HOMEDRIVE") + os.Getenv("HOMEPATH")
		if home == "" {
			home = os.Getenv("USERPROFILE")
		}
		return home
	}
	return os.Getenv("HOME")
}

func (uc UserConfig) Configfile() string {
	return filepath.Join(uc.UserHomeDir(), configfilename)
}

func (uc UserConfig) Load() map[string]string {
	retv := make(map[string]string)
	retv["mailaddress"] = "john@vanzantvoort.org"
	retv["company"] = "JDC"
	retv["license"] = "MIT"
	retv["copyright"] = "John van Zantvoort"

	cfg, err := ini.Load(uc.Configfile())
	if err != nil {
		fmt.Printf("Fail to read file: %v\n", err)
		return retv
	}
	retv["mailaddress"] = cfg.Section("user").Key("mailaddress").String()
	retv["company"] = cfg.Section("user").Key("company").String()

	return retv
}

func Ask(question string, input string) string {
	reader := bufio.NewReader(os.Stdin)
	if len(input) > 0 {
		question += "[" + input + "]"
	}

	fmt.Printf("%s: ", question)
	text, err := reader.ReadString('\n')
	if err != nil {
		panic("at the disco")
	}
	text = strings.TrimSuffix(text, "\n")
	if len(input) > 0 && len(text) < 1 {
		return input
	}
	return text

}

func (uc UserConfig) Set(parameter string, value string) {
	sectionname := "user"
	cfg, err := ini.Load(uc.Configfile())
	if err != nil {
		cfg = ini.Empty()
	}
	if _, err := cfg.GetSection(sectionname); err != nil {
		cfg.NewSection(sectionname)
	}
	cfg.Section(sectionname).Key(parameter).SetValue(value)
	cfg.SaveTo(uc.Configfile())
}

func main() {
	uc := UserConfig{}
	mymap := uc.Load()

	mailaddress := Ask("Email", mymap["mailaddress"])
	uc.Set("mailaddress", mailaddress)

	company := Ask("Company", mymap["company"])
	uc.Set("company", company)

	copyright := Ask("Copyright", mymap["copyright"])
	uc.Set("copyright", copyright)

	license := Ask("License", mymap["license"])
	uc.Set("license", license)
}

// vim: noexpandtab filetype=go
