
/* ============================================================
* Falkon - Qt web browser
* Copyright (C) 2010-2018 David Rosca <nowrep@gmail.com>
* Copyright (C) 2020-2025 Juraj Oravec <jurajoravec@mailo.com>
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
* ============================================================ */

#include "aboutdialog.h"
#include "ui_aboutdialog.h"
#include "browserwindow.h"
#include "mainapplication.h"
#include "webpage.h"
#include "useragentmanager.h"
#include "../config.h"

#include <QFont>
#include <QWebEnginePage>
#include <QWebEngineProfile>
#include <QtWebEngineCoreVersion>

AboutDialog::AboutDialog(QWidget* parent)
    : QDialog(parent)
    , ui(new Ui::AboutDialog)
{
    setAttribute(Qt::WA_DeleteOnClose);

    ui->setupUi(this);

    // browser:e8y6 - application branding
    setWindowTitle(QStringLiteral("About browser:e8y6"));

    // Replace Falkon's graphical logo with text-only branding.
    ui->label->setPixmap(QPixmap());
    ui->label->setText(QStringLiteral("browser:e8y6"));
    ui->label->setAlignment(Qt::AlignCenter);

    QFont brandingFont = ui->label->font();
    brandingFont.setPointSize(26);
    brandingFont.setBold(true);
    ui->label->setFont(brandingFont);

    // Keep the branding readable across Qt themes.
    ui->label->setMinimumWidth(300);
    ui->label->setMinimumHeight(75);

    showAbout();
}

AboutDialog::~AboutDialog()
{
    delete ui;
}

void AboutDialog::showAbout()
{
    QString aboutHtml;
    aboutHtml += QSL("<div style='margin:0px 20px;'>");

    // Application version
    aboutHtml += tr("<p><b>Application version %1</b><br/>").arg(
#ifdef FALKON_GIT_REVISION
                       QString(QSL("%1 (%2)")).arg(
                           QString::fromLatin1(Qz::VERSION),
                           QL1S(FALKON_GIT_REVISION)
                       )
#else
                       QString::fromLatin1(Qz::VERSION)
#endif
                   );

    // QtWebEngine version
    aboutHtml += tr("<b>QtWebEngine version %1</b></p>")
                     .arg(QStringLiteral(QTWEBENGINECORE_VERSION_STR));

    // browser:e8y6 project description and attribution.
    aboutHtml += QSL("<p>A lightweight, customizable web browser "
                     "based on KDE Falkon, with custom branding "
                     "and integration for os:e8y6.</p>");

    aboutHtml += QSL("<p>Developed by jpeevi<br/>"
                     "<a href='mailto:jpeevi@hotmail.com'>"
                     "jpeevi@hotmail.com</a></p>");

    aboutHtml += QSL("<p><b>Based on KDE Falkon</b></p>");

    // Preserve original Falkon contributor credits.
    aboutHtml += QSL("<p>");

    for (const auto &author : Qz::AUTHORS) {
        aboutHtml += QStringLiteral("&copy; %1-%2 %3<br/>").arg(
            QString::number(author.copyrightBegin),
            QString::number(author.copyrightEnd),
            author.name
        );
    }

    // Preserve upstream project attribution.
    aboutHtml += QStringLiteral("<a href=%1>%1</a></p>")
                     .arg(QString::fromLatin1(Qz::WWWADDRESS));

    // Preserve browser user-agent information.
    aboutHtml += QStringLiteral("<p>")
                     + mApp->userAgentManager()->defaultUserAgent()
                     + QStringLiteral("</p>");

    aboutHtml += QStringLiteral("</div>");

    ui->textLabel->setText(aboutHtml);

    setFixedHeight(sizeHint().height());
}
