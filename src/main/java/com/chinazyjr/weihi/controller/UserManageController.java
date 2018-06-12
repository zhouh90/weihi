package com.chinazyjr.weihi.controller;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.util.Random;

import javax.imageio.ImageIO;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.chinazyjr.weihi.utils.MD5Util;
import com.chinazyjr.weihi.utils.R;

/**
 * @author 周 浩
 * @email zhou_eric90@163.com
 * @date 2018年4月12日 上午10:59:12
 * @描述
 */
@Controller
@RequestMapping("/sys/user")
public class UserManageController {

	private static final Logger logger = LoggerFactory.getLogger(UserManageController.class);

	@RequestMapping("/captcha")
	@ResponseBody
	public void captcha(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws ServletException, IOException {
		int width = 63;
		int height = 37;
		Random random = new Random();
		response.setHeader("Pragma", "No-cache");
		response.setHeader("Cache-Control", "no-cache");
		response.setDateHeader("Expires", 0);

		// 生成缓冲区image类
		BufferedImage image = new BufferedImage(width, height, 1);
		// 产生image类的Graphics用于绘制操作
		Graphics g = image.getGraphics();
		// Graphics类的样式
		g.setColor(this.getRandColor(200, 250));
		g.setFont(new Font("Times New Roman", 0, 28));
		g.fillRect(0, 0, width, height);
		// 绘制干扰线
		for (int i = 0; i < 40; i++) {
			g.setColor(this.getRandColor(130, 200));
			int x = random.nextInt(width);
			int y = random.nextInt(height);
			int x1 = random.nextInt(12);
			int y1 = random.nextInt(12);
			g.drawLine(x, y, x + x1, y + y1);
		}
		// 绘制字符
		String strCode = "";
		for (int i = 0; i < 4; i++) {
			String rand = String.valueOf(random.nextInt(10));
			strCode = strCode + rand;
			g.setColor(new Color(20 + random.nextInt(110), 20 + random.nextInt(110), 20 + random.nextInt(110)));
			g.drawString(rand, 13 * i + 6, 28);
		}
		// 将字符保存到session中用于前端的验证 ---- 后期将会保存到redis
		session.setAttribute("captcha", strCode);
		g.dispose();

		ImageIO.write(image, "JPEG", response.getOutputStream());
		response.getOutputStream().flush();
	}

	private Color getRandColor(int fc, int bc) {
		Random random = new Random();
		if (fc > 255)
			fc = 255;
		if (bc > 255)
			bc = 255;
		int r = fc + random.nextInt(bc - fc);
		int g = fc + random.nextInt(bc - fc);
		int b = fc + random.nextInt(bc - fc);
		return new Color(r, g, b);
	}

	@RequestMapping("/doLogin")
	@ResponseBody
	public R doLogin(HttpServletRequest request, HttpServletResponse response) {
		logger.info("后台执行用户登录doLogin");
		String realValidateCode = (String) request.getSession(true).getAttribute("captcha");
		String validateCode = request.getParameter("captcha");// 验证码
		if (validateCode == null || !validateCode.equalsIgnoreCase(realValidateCode)) {
			return R.error(-1, "验证码不正确");
		}
		String userName = request.getParameter("userName");// 账号
		String password = request.getParameter("passWord");// 密码
		if ("chat_admin1".equals(userName) && "d0a20aa5c69fbff3a0c094a5ebcd6de7".equals(password)) {
			logger.info("chat_admin1 登录成功！");
			request.getSession().setAttribute("userInfo", MD5Util.md5(userName + "@" + password));
			return R.ok().put("nickName", "Eric");
		}
		if ("chat_admin2".equals(userName) && "d0a20aa5c69fbff3a0c094a5ebcd6de7".equals(password)) {
			logger.info("chat_admin2 登录成功！");
			request.getSession().setAttribute("userInfo", MD5Util.md5(userName + "@" + password));
			return R.ok().put("nickName", "John");
		}
		return R.error(-1, "用户名或密码不正确");
	}

	@RequestMapping("/logout")
	public String logout(HttpServletResponse response, HttpServletRequest request) {
		if (request.getSession().getAttribute("userInfo") != null) {
			request.getSession().removeAttribute("userInfo");
		}
		logger.info("logout");
		return "/login";
	}

}
