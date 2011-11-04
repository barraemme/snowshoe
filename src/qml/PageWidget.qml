/****************************************************************************
 *   Copyright (C) 2011  Instituto Nokia de Tecnologia (INdT)               *
 *                                                                          *
 *   This file may be used under the terms of the GNU Lesser                *
 *   General Public License version 2.1 as published by the Free Software   *
 *   Foundation and appearing in the file LICENSE.LGPL included in the      *
 *   packaging of this file.  Please review the following information to    *
 *   ensure the GNU Lesser General Public License version 2.1 requirements  *
 *   will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.   *
 *                                                                          *
 *   This program is distributed in the hope that it will be useful,        *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          *
 *   GNU Lesser General Public License for more details.                    *
 ****************************************************************************/

import QtQuick 2.0
import QtWebKit 3.0
import Snowshoe 1.0

Item {
    id: root

    property alias url: webView.url
    property alias webView: webView
    property bool isLoading: false
    property string title: "New Tab"
    property string currentUrl
    property bool active: false

    property variant tab;

    onActiveChanged: { currentUrl = urlBar.text }

    DesktopWebView {
        id: webView
        anchors.fill: parent

        visible: false

        onLoadStarted: {
            root.isLoading = true;
            visible = true;
            newTab.visible = false;
            if (tab.active && !focus)
                forceActiveFocus();
        }

        onLoadSucceeded: {
            root.isLoading = false
        }

        onLoadFailed: {
            root.isLoading = false
            if (errorType == DesktopWebView.NetworkError && errorCode == NetworkReply.OperationCanceledError)
                return;
            loadUrl(fallbackUrl(url))
        }

        onUrlChanged: {
            currentUrl = url
        }

        onLinkHovered: {
            hoveredLink.text = url.toString()
        }

        onTitleChanged: { root.title = title }

        onDownloadRequested: {
            downloadItem.destinationPath = BrowserObject.decideDownloadPath(downloadItem.suggestedFilename)
            downloadItem.start()
        }

        function navigationPolicyForUrl(url, button, modifiers) {
            if (button == Qt.MiddleButton
                || (button == Qt.LeftButton && modifiers & Qt.ControlModifier)) {
                browserView.addNewTabWithUrl(url)
                return DesktopWebView.IgnorePolicy
            }
            return DesktopWebView.UsePolicy
        }
    }

    function loadUrl(url)
    {
        webView.load(url)
        currentUrl = url
    }

    function fallbackUrl(url)
    {
        return "http://www.google.com/search?q=" + url;
    }

    function stop() {
        webView.navigation.stop()
    }

    function reload() {
        webView.navigation.reload()
    }

    NewTab {
        id: newTab
        anchors.fill: parent
    }

    HoveredLinkBar {
        id: hoveredLink
        anchors.bottom: parent.bottom
        anchors.left: parent.left
    }
}
