Redmine Milkode plugin
====================================
A Redmine plugin adds fast code search with [Milkode](http://milkode.ongaeshi.me/wiki/Main_Page).

Author
------------------------------
* @suer
* (thanks) @mallowlabs

Install
------------------------------
Type below commands:

    $ cd $RAILS_ROOT/plugins
    $ git clone git://github.com/suer/redmine_readme.git
    $ cd $RAILS_ROOT
    $ bundle install

Then, restart your redmine.

Upgrade from 0.0.1
-----------------------------

    $ bundle update
    $ cd $RAILS_ROOT/tmp/milkode/db
    $ bundle exec milk rebuild --all

Requirements
------------------------------
* Redmine 2.0 or later

License
------------------------------
The MIT License (MIT)
Copyright (c) 2012 suer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

