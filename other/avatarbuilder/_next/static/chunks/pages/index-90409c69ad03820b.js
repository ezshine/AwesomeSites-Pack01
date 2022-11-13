(self.webpackChunk_N_E = self.webpackChunk_N_E || []).push([
	[405], {
		8312: function(a, b, c) {
			(window.__NEXT_P = window.__NEXT_P || []).push(["/", function() {
				return c(3849)
			}])
		},
		3849: function(B, b, a) {
			"use strict";
			a.r(b), a.d(b, {
				"__N_SSP": function() {
					return aQ
				},
				default: function() {
					return aR
				}
			});
			var e, f, C = a(5893),
				g = a(9008),
				D = a.n(g),
				E = a(7294),
				F = a(1163),
				G = a(9521),
				h = a(8172),
				H = a.n(h),
				I = a(4924),
				i = a(4184),
				J = a.n(i),
				j = a(8647),
				K = a.n(j),
				L = function(a) {
					var b = a.loaded;
					return (0, C.jsx)("div", {
						className: J()(K().loader, (0, I.Z)({}, K().hidden, b)),
						children: (0, C.jsx)("div", {
							className: K().inner
						})
					})
				},
				k = a(7342),
				M = a.n(k),
				N = a(6042),
				O = a(9534),
				l = a(5675),
				P = a.n(l),
				m = a(6542),
				Q = a.n(m),
				R = function(a) {
					var c = a.className,
						d = (0, O.Z)(a, ["className"]),
						b = (0, E.useState)(!1),
						e = b[0],
						f = b[1];
					return (0, C.jsx)(P(), (0, N.Z)({
						className: J()(Q().image, (0, I.Z)({}, Q().loaded, e), c),
						onLoadingComplete: function() {
							return f(!0)
						}
					}, d))
				},
				S = a(181),
				n = a(2332),
				T = a.n(n),
				U = a(3935),
				V = a(2548),
				W = a(9218),
				o = a(8678),
				X = a.n(o),
				Y = function(a) {
					var e = a.className,
						f = a.containerClassName,
						g = a.visible,
						b = a.onClose,
						h = a.hideClose,
						i = a.children,
						c = (0, E.useState)(!1),
						j = c[0],
						k = c[1];
					(0, E.useEffect)(function() {
						return k(!0)
					}, []), (0, W.y1)("esc", b, {
						enableOnTags: ["INPUT"]
					});
					var d = (0, E.useRef)(null);
					return j ? (0, U.createPortal)((0, C.jsx)(V.Z, {
						classNames: "fade-in",
						in: g,
						timeout: 300,
						unmountOnExit: !0,
						nodeRef: d,
						children: (0, C.jsxs)("div", {
							className: J()(X().modal, e),
							onClick: b,
							ref: d,
							children: [!h && (0, C.jsx)("button", {
								className: J()("button-icon", X().close),
								onClick: b,
								children: (0, C.jsx)("svg", {
									width: "12",
									height: "12",
									children: (0, C.jsx)("path", {
										d: "M10.772 1.226a1.25 1.25 0 0 1 .091 1.666l-.091.101-3.006 3.005 3.006 3.006a1.25 1.25 0 0 1-1.666 1.859l-.101-.091-3.005-3.006-3.005 3.005a1.25 1.25 0 0 1-1.859-1.666l.091-.101 3.005-3.005-3.005-3.005a1.25 1.25 0 0 1 1.666-1.859l.101.091 3.005 3.004 3.005-3.005a1.25 1.25 0 0 1 1.768 0z"
									})
								})
							}), (0, C.jsx)("div", {
								className: f,
								onClick: function(a) {
									return a.stopPropagation()
								},
								children: i
							})]
						})
					}), document.body) : null
				},
				p = a(8644),
				Z = a.n(p),
				$ = function(a) {
					var b = a.className;
					return (0, C.jsxs)("div", {
						className: J()(Z().created, b),
						children: [(0, C.jsx)("svg", {
							width: "22",
							height: "23",
							fill: "none",
							children: (0, C.jsx)("path", {
								d: "M9 .655a4 4 0 0 1 4 0l6.392 3.691a4 4 0 0 1 2 3.464v7.381a4 4 0 0 1-2 3.464L13 22.345a4 4 0 0 1-4 0l-6.392-3.691a4 4 0 0 1-2-3.464V7.809a4 4 0 0 1 2-3.464L9 .655z",
								fill: "#8b9d9e"
							})
						}), (0, C.jsxs)("span", {
							children: ["Created by", " ", (0, C.jsx)("a", {
								href: "https://ui8.net",
								target: "_blank",
								rel: "noreferrer",
								children: "UI8"
							})]
						})]
					})
				},
				_ = function(a) {
					var d = a.visible,
						b = a.onClose,
						e = a.color,
						c = a.avatar,
						f = a.avatarId,
						g = a.onDownload;
					return (0, C.jsxs)(Y, {
						className: T().modal,
						containerClassName: T().download,
						visible: d,
						onClose: b,
						children: [(0, C.jsx)("div", {
							className: T().avatar,
							style: {
								backgroundColor: e
							},
							children: c && (0, C.jsx)(R, {
								src: c,
								width: 400,
								height: 400,
								alt: "Avatar"
							})
						}), (0, C.jsxs)("div", {
							className: T().inner,
							children: [(0, C.jsx)("h2", {
								className: J()("title", T().title),
								children: "You look great!"
							}), (0, C.jsxs)("div", {
								className: J()("content", T().content),
								children: ["Your Peep is downloading and is free to use for personal or commercial projects. If the download doesn\u2019t happen automatically ", (0, C.jsx)("button", {
									onClick: g,
									children: "click here"
								}), "."]
							}), (0, C.jsxs)("div", {
								className: T().buttons,
								children: [(0, C.jsx)(S.Z, {
									className: T().button,
									title: "Look what I just made with Peeps Avatar Maker from @ui8",
									url: "https://peeps.ui8.net?p=".concat(f),
									children: (0, C.jsxs)("span", {
										className: "button",
										children: [(0, C.jsx)("svg", {
											width: "21",
											height: "16",
											children: (0, C.jsx)("path", {
												d: "M18 4.002l1.875-2.025a.48.48 0 0 0-.415-.802l-2.349.311C16.378.579 15.256 0 14 0a4 4 0 0 0-4 4 3.99 3.99 0 0 0 .288 1.492c-2.996-.07-6.205-.663-7.827-3.877-.201-.398-.776-.421-.904.006C.383 5.541 2.449 10.635 7 12c-1.135 1.11-4.054 1.411-6.442 1.193-.465-.043-.756.487-.397.785C2.163 15.636 4.941 16 7.5 16c6.499 0 10.999-5.499 10.5-11.998z"
											})
										}), "Tweet it"]
									})
								}), (0, C.jsx)("button", {
									className: J()("button-stroke", T().button),
									onClick: b,
									children: "Try it again"
								})]
							}), (0, C.jsx)($, {
								className: T().created
							})]
						})]
					})
				},
				q = a(5901),
				aa = a.n(q),
				ab = [{
					title: "Expression",
					option: "face",
					length: 12
				}, {
					title: "Head",
					option: "hair",
					length: 12
				}, {
					title: "Eyebrows",
					option: "eyebrows",
					length: 8
				}, {
					title: "Sunglasses",
					option: "sunglasses",
					length: 12
				}, {
					title: "Clothes",
					option: "clothes",
					length: 12
				}, {
					title: "Necklaces",
					option: "necklace",
					length: 12
				}, {
					title: "Earrings",
					option: "earrings",
					length: 12
				}, {
					title: "Tattoo",
					option: "tattoo",
					length: 12
				}, ],
				ac = function() {
					return (0, C.jsxs)("svg", {
						width: "28",
						height: "28",
						viewBox: "0 0 28 28",
						fill: "none",
						xmlns: "http://www.w3.org/2000/svg",
						children: [(0, C.jsx)("rect", {
							width: "28",
							height: "28",
							rx: "14",
							fill: "#00B2B2",
							fillOpacity: "0.2"
						}), (0, C.jsx)("path", {
							d: "M12.3333 17.3333L9 14",
							stroke: "#00B2B2",
							strokeWidth: "4",
							strokeLinecap: "round",
							strokeLinejoin: "round"
						}), (0, C.jsx)("path", {
							d: "M18.9997 10.6667L12.333 17.3334",
							stroke: "#00B2B2",
							strokeWidth: "4",
							strokeLinecap: "round",
							strokeLinejoin: "round"
						})]
					})
				},
				ad = function(a) {
					var b = a.visible,
						c = a.onClose,
						d = 1;
					return ab.forEach(function(a) {
						return d *= a.length
					}), (0, C.jsxs)(Y, {
						className: aa().modal,
						containerClassName: aa().about,
						visible: b,
						onClose: c,
						children: [(0, C.jsx)("div", {
							className: J()("title", aa().title),
							children: "How to use Peeps?"
						}), (0, C.jsxs)("div", {
							className: J()("content", aa().content),
							children: [(0, C.jsx)("p", {
								children: "Peeps is an interactive 3D avatar builder brought to you by the UI8 team. This initial version of our builder is 100% free to use for personal and commercial projects."
							}), (0, C.jsx)("p", {
								children: "You can use Peeps in your social profiles, social media posts, design projects, or anywhere you can use a friendly face. The only thing you cannot do, is resell or redistribute them."
							}), (0, C.jsxs)("p", {
								children: ["To get started, customize your Peep by selecting different faces (expressions), headgear, eyewear, etc., giving you over ", (0, C.jsx)("strong", {
									children: d.toLocaleString()
								}), " ", "possibilities."]
							}), (0, C.jsx)("p", {
								children: "Once you\u2019re happy with your creation, clicking the download button will get you 2 files:"
							})]
						}), (0, C.jsxs)("ul", {
							className: aa().images,
							children: [(0, C.jsxs)("li", {
								children: [(0, C.jsx)(ac, {}), " 1000x1000 PNG + Background"]
							}), (0, C.jsxs)("li", {
								children: [(0, C.jsx)(ac, {}), " 1000x1000 PNG + Alpha (Transparent)"]
							})]
						}), (0, C.jsxs)("div", {
							className: aa().foot,
							children: [(0, C.jsx)($, {}), (0, C.jsxs)("div", {
								className: aa().terms,
								children: [(0, C.jsx)("a", {
									href: "https://ui8.net/terms",
									children: "Terms"
								}), " &", " ", (0, C.jsx)("a", {
									href: "https://ui8.net/licensing",
									children: "Licensing"
								})]
							})]
						})]
					})
				},
				ae = function(a) {
					var b = "",
						c = Object.keys(a);
					return c.forEach(function(d, e) {
						b += a[d], e + 1 < c.length && (b += "-")
					}), b
				},
				af = function(a) {
					var e = a.loaded,
						k = a.logged,
						l = a.openAuth,
						f = a.params,
						m = a.downloadRef,
						g = a.color,
						h = a.avatar,
						b = (0, E.useState)(!1),
						i = b[0],
						n = b[1],
						c = (0, E.useState)(!1),
						j = c[0],
						o = c[1],
						d = function() {
							// k ? (n(!0), m.current(g, ae(f))) : l()
							var canvas = document.querySelector("canvas");
							canvas.toBlob(function(blob) {
							    saveAs(blob, "myAvatar.png");
							});
						};
					return (0, C.jsxs)(C.Fragment, {
						children: [(0, C.jsxs)("div", {
							className: M().header,
							children: [e && (0, C.jsxs)(C.Fragment, {
								children: [(0, C.jsxs)("button", {
									className: J()("button", M().download),
									onClick: d,
									children: [(0, C.jsx)("svg", {
										width: "20",
										height: "20",
										children: (0, C.jsx)("path", {
											d: "M10.833 9a1.25 1.25 0 0 1 1.244 1.122l.006.128v4.898l1.408-1.407a1.25 1.25 0 0 1 1.666-.091l.101.091a1.25 1.25 0 0 1 .091 1.666l-.091.101-3.542 3.542c-.031.031-.064.061-.098.089l.098-.089c-.039.039-.08.075-.123.108l-.082.058-.034.021-.071.04-.048.023-.076.032-.041.015-.071.022-.058.015-.069.014-.053.008-.079.007-.05.002h-.027 0l-.054-.001-.044-.003.098.004a1.26 1.26 0 0 1-.185-.014l-.042-.007-.083-.018-.043-.012-.069-.023-.056-.022-.046-.02c-.071-.033-.139-.072-.204-.119l-.076-.059-.023-.02-.071-.068-.011-.012-3.333-3.542a1.25 1.25 0 0 1 1.722-1.808l.099.094 1.172 1.246V10.25A1.25 1.25 0 0 1 10.833 9zM7.917.25c2.841 0 5.33 1.615 6.642 4.105l.107.211.156.016c2.642.316 4.654 2.523 4.758 5.279l.004.225a1.25 1.25 0 1 1-2.5 0c0-1.66-1.192-2.948-2.743-3.038l-.174-.005h-.333a1.25 1.25 0 0 1-1.173-.818c-.772-2.098-2.617-3.475-4.744-3.475-2.718 0-5 2.351-5 5.189a5.27 5.27 0 0 0 .844 2.881 1.25 1.25 0 0 1-2.098 1.36A7.77 7.77 0 0 1 .417 7.939C.417 3.737 3.801.25 7.917.25z"
										})
									}), "Download"]
								})]
							})]
						}), (0, C.jsx)(_, {
							visible: i,
							onClose: function() {
								n(!1)
							},
							color: g,
							avatarId: ae(f),
							avatar: h,
							onDownload: d
						}), (0, C.jsx)(ad, {
							visible: j,
							onClose: function() {
								return o(!1)
							}
						})]
					})
				},
				r = a(8965),
				ag = a.n(r),
				ah = a(9834),
				ai = a(5907),
				s = a(7316),
				aj = a.n(s),
				ak = function(a) {
					var f = a.actionClassName,
						b = a.color,
						c = a.setColor,
						d = (0, E.useState)(!1),
						g = d[0],
						h = d[1];
					(0, W.y1)("esc", function() {
						return h(!1)
					}, {
						enableOnTags: ["INPUT"]
					});
					var e = (0, E.useRef)(null);
					return (0, C.jsxs)(ah.default, {
						onOutsideClick: function() {
							return h(!1)
						},
						children: [(0, C.jsx)("button", {
							className: J()("button-icon", f),
							onClick: function() {
								return h(!g)
							},
							children: (0, C.jsx)("span", {
								style: {
									backgroundColor: b
								}
							})
						}), (0, C.jsx)(V.Z, {
							classNames: "fade-in",
							in: g,
							timeout: 300,
							unmountOnExit: !0,
							nodeRef: e,
							children: (0, C.jsxs)("div", {
								className: J()("picker", aj().picker),
								ref: e,
								children: [(0, C.jsx)(ai.gW, {
									color: b,
									onChange: c
								}), (0, C.jsxs)("div", {
									className: aj().field,
									children: [(0, C.jsx)("div", {
										className: aj().label,
										children: "Hex"
									}), (0, C.jsx)("div", {
										className: aj().box,
										children: (0, C.jsx)(ai.ZE, {
											color: b,
											onChange: c
										})
									})]
								})]
							})
						})]
					})
				},
				al = function(a) {
					var d = a.color,
						e = a.setColor,
						b = a.lightSkin,
						h = a.setLightSkin,
						i = a.params,
						j = a.setParams,
						c = (0, E.useState)(0),
						f = c[0],
						k = c[1],
						l = (0, F.useRouter)(),
						m = function(a, b) {
							j(function(d) {
								var c = (0, N.Z)({}, d);
								// l.push({
								// 	query: {
								// 		p: ae(c)
								// 	}
								// })
								return c[a] = b,  c;
							})
						},
						n = function(a) {
							return Math.floor(Math.random() * a) + 1
						},
						g = ab[f];
					return (0, C.jsxs)("div", {
						className: ag().editor,
						children: [(0, C.jsxs)("div", {
							className: ag().actions,
							children: [(0, C.jsx)("button", {
								className: J()("button-icon", ag().action, (0, I.Z)({}, ag().active, b)),
								onClick: function() {
									return h(!0)
								},
								children: (0, C.jsx)("span", {
									className: ag().skin1
								})
							}), (0, C.jsx)("button", {
								className: J()("button-icon", ag().action, (0, I.Z)({}, ag().active, !b)),
								onClick: function() {
									return h(!1)
								},
								children: (0, C.jsx)("span", {
									className: ag().skin2
								})
							})]
						}), (0, C.jsx)("div", {
							className: J()(ag().actions, ag().actionsColor),
							children: (0, C.jsx)(ak, {
								actionClassName: ag().action,
								color: d,
								setColor: e
							})
						}), (0, C.jsxs)("div", {
							className: ag().head,
							children: [ab.map(function(b, a) {
								return (0, C.jsx)("button", {
									className: J()(ag().tab, (0, I.Z)({}, ag().active, a === f)),
									onClick: function() {
										return k(a)
									},
									children: b.title
								}, a)
							}), (0, C.jsxs)("button", {
								className: J()(ag().tab, ag().tabRandomize),
								onClick: function() {
									j({
										face: n(12),
										hair: n(12),
										eyebrows: n(8),
										sunglasses: n(12),
										clothes: n(12),
										necklace: n(12),
										earrings: n(12),
										tattoo: n(12)
									})
								},
								children: ["Randomize", (0, C.jsx)("svg", {
									width: "24",
									height: "24",
									children: (0, C.jsx)("path", {
										d: "M21 10.75A1.25 1.25 0 0 1 22.25 12c0 5.661-4.589 10.25-10.25 10.25a10.23 10.23 0 0 1-6.75-2.535v.785a1.25 1.25 0 0 1-1.122 1.244L4 21.75a1.25 1.25 0 0 1-1.244-1.122L2.75 20.5v-4a1.25 1.25 0 0 1 1.122-1.244L4 15.25h.189a1.25 1.25 0 0 1 .037 0H8a1.25 1.25 0 0 1 .128 2.494L8 17.75l-1.196.001C8.2 19.013 10.035 19.75 12 19.75A7.75 7.75 0 0 0 19.75 12 1.25 1.25 0 0 1 21 10.75zm-5-2a1.25 1.25 0 0 1-.128-2.494L16 6.25h1.197c-1.396-1.263-3.232-2-5.197-2A7.75 7.75 0 0 0 4.25 12a1.25 1.25 0 1 1-2.5 0C1.75 6.339 6.339 1.75 12 1.75a10.23 10.23 0 0 1 6.751 2.536L18.75 3.5a1.25 1.25 0 0 1 1.122-1.244L20 2.25a1.25 1.25 0 0 1 1.244 1.122l.006.128v4a1.25 1.25 0 0 1-1.122 1.244L20 8.75h-4z"
									})
								})]
							})]
						}), (0, C.jsx)("div", {
							className: ag().previews,
							children: Array.from(Array(g.length).keys()).map(function(a) {
								return (0, C.jsx)("div", {
									className: J()(ag().preview, (0, I.Z)({}, ag().active, i[g.option] === a + 1)),
									onClick: function() {
										return m(g.option, a + 1)
									},
									children: (0, C.jsx)(R, {
										src: "./images/previews/".concat(b ? "light" : "dark", "/").concat(g.option, "/").concat(a + 1, ".png"),
										layout: "fill",
										alt: "Preview ".concat(a)
									})
								}, a)
							})
						})]
					})
				},
				am = a(6135),
				an = a(6665),
				ao = a(6388),
				t = a(6910),
				ap = a.n(t),
				c = a(7568),
				u = a(4051),
				d = a.n(u),
				aq = a(8626),
				ar = a(1901),
				v = a(3162),
				as = a.n(v),
				w = a(9669),
				at = a.n(w),
				au = (e = (0, c.Z)(d().mark(function a(b, c, e) {
					var f, g;
					return d().wrap(function(a) {
						for (;;) switch (a.prev = a.next) {
							case 0:
								return a.next = 2, fetch(b);
							case 2:
								return f = a.sent, a.next = 5, f.arrayBuffer();
							case 5:
								return g = a.sent, a.abrupt("return", new File([g], c, {
									type: e
								}));
							case 7:
							case "end":
								return a.stop()
						}
					}, a)
				})), function(a, b, c) {
					return e.apply(this, arguments)
				}),
				av = (f = (0, c.Z)(d().mark(function a(b, c) {
					var e, f;
					return d().wrap(function(a) {
						for (;;) switch (a.prev = a.next) {
							case 0:
								return a.next = 2, au(b, "".concat(c, ".png"), "image/png");
							case 2:
								return e = a.sent, a.next = 5, at().post("/api/upload", {
									name: e.name,
									type: e.type
								});
							case 5:
								if (!(f = a.sent.data).url) {
									a.next = 9;
									break
								}
								return a.next = 9, at().put(f.url, e, {
									headers: {
										"Content-type": e.type,
										"Access-Control-Allow-Origin": "*"
									}
								});
							case 9:
							case "end":
								return a.stop()
						}
					}, a)
				})), function(a, b) {
					return f.apply(this, arguments)
				}),
				aw = function(k) {
					var F = k.width,
						y = k.height,
						G = k.downloadRef,
						H = k.setAvatar,
						n = k.lightSkin,
						g = k.params;
					(0, E.useEffect)(function() {
						G.current = N
					}, []);
					var l = (0, ar.w)(),
						I = l.gl,
						J = l.scene,
						z = l.camera,
						K = window.devicePixelRatio;
					(0, E.useEffect)(function() {
						z.zoom = y / 3, z.updateProjectionMatrix()
					}, [z, y]);
					var A, L = function() {
							I.setSize(1e3 / K, 1e3 / K)
						},
						M = function() {
							I.setSize(F, y)
						},
						N = (A = (0, c.Z)(d().mark(function a(b, c) {
							var e, f;
							return d().wrap(function(a) {
								for (;;) switch (a.prev = a.next) {
									case 0:
										L(), I.render(J, z), e = I.domElement.toDataURL(), as().saveAs(e, "peeps-avatar-alpha.png"), M(), L(), I.setClearColor(b), I.render(J, z), f = I.domElement.toDataURL(), as().saveAs(f, "peeps-avatar.png"), M(), I.setClearColor(0, 0), H(e), av(e, c);
									case 14:
									case "end":
										return a.stop()
								}
							}, a)
						})), function(a, b) {
							return A.apply(this, arguments)
						}),
						o = (0, aq.L)("./models/peeps.gltf"),
						e = o.nodes,
						a = o.materials,
						b = function(b, a) {
							return b + (a < 10 ? "00" : "0") + a
						},
						h = g.face,
						p = g.hair,
						B = g.eyebrows,
						m = g.sunglasses,
						q = g.clothes,
						r = g.necklace,
						s = g.earrings,
						t = g.tattoo,
						u = p - 1,
						i = m - 1,
						v = r - 1,
						f = s - 1,
						w = 8 === h || 11 === h ? h : null,
						j = 1 === t ? n ? "SKIN FACE BODY LIGHT" : "SKIN FACE BODY DARK" : b("TATTOO".concat(n ? "LIGHT" : "DARK", "."), t - 1),
						D = (0, E.useRef)(null),
						x = (0, E.useState)(null),
						O = x[0],
						P = x[1];
					return (0, ar.x)(function(b) {
						var a = b.clock.getElapsedTime();
						D.current && (O ? (a > O && a <= O + .45 && (D.current.rotation.y = a - O), a > O + .45 && a <= O + 1.35 && (D.current.rotation.y = O + .9 - a), a > O + 1.35 && a <= O + 1.8 && (D.current.rotation.y = a - (O + 1.8))) : P(Math.ceil(a)))
					}), (0, C.jsxs)("mesh", {
						position: [0, -0.28, 0],
						ref: D,
						children: [(0, C.jsx)("mesh", {
							receiveShadow: !0,
							geometry: e[b("head", h)].geometry,
							material: a[j]
						}), 1 !== p && (0, C.jsx)("mesh", {
							castShadow: !0,
							geometry: e[b("hair", u)].geometry,
							material: a[b("HAIR.", u)]
						}), (0, C.jsx)("mesh", {
							geometry: e.ears000.geometry,
							material: a[j]
						}), (0, C.jsx)("mesh", {
							castShadow: !0,
							geometry: e[b("eyebrows", B)].geometry,
							material: a["EYEBROWS.001"]
						}), (0, C.jsx)("mesh", {
							castShadow: !0,
							geometry: e.eyes000.geometry,
							material: a[j]
						}), (0, C.jsx)("mesh", {
							geometry: e.nose000.geometry,
							material: a[j]
						}), (0, C.jsx)("mesh", {
							geometry: e[b("teeth", 6 === h || 9 === h || 10 === h ? 2 : h)].geometry,
							material: a[j]
						}), w && (0, C.jsx)("mesh", {
							geometry: e[b("tongue", w)].geometry,
							material: a[j]
						}), 1 !== m && (0, C.jsx)("mesh", {
							geometry: e[b("frame", i)].geometry,
							material: 9 === i ? a["GOLD.001"] : a[b("FRAME.", i)]
						}), 1 !== m && (0, C.jsx)("mesh", {
							geometry: e[b("glass", i)].geometry,
							material: 9 === i ? a["GLASS.008"] : 11 === i ? a["GLASS.010"] : a[b("GLASS.", i)]
						}), (0, C.jsx)("mesh", {
							geometry: e.neck000.geometry,
							material: a[j]
						}), (0, C.jsx)("mesh", {
							geometry: e[b("clothes", q)].geometry,
							material: a[b("CLOTHES.", q)]
						}), 1 !== r && (0, C.jsx)("mesh", {
							geometry: e[b("necklace", v)].geometry,
							material: a[b("NECKLACE.", v)]
						}), 1 !== s && (0, C.jsx)("mesh", {
							geometry: e[b("earrings", f)].geometry,
							material: 1 === f ? a.ACCESSORIES_black : 3 === f ? a["GOLD.002"] : 2 === f || 4 === f || 5 === f || 6 === f || 11 === f || 12 === f ? a["GOLD.001"] : a[b("EARRINGS.", f)]
						})]
					})
				},
				ax = function(a) {
					var f = a.downloadRef,
						g = a.setAvatar,
						h = a.lightSkin,
						i = a.params,
						b = (0, ao.Z)(),
						j = b.ref,
						c = b.width,
						d = b.height,
						e = void 0 === d ? 1 : d;
					return (0, C.jsx)("div", {
						className: ap().scene,
						ref: j,
						children: (0, C.jsxs)(am.Xz, {
							className: ap().canvas,
							camera: {
								zoom: e / 3
							},
							orthographic: !0,
							gl: {
								antialias: !0,
								preserveDrawingBuffer: !0
							},
							shadows: !0,
							legacy: !0,
							children: [(0, C.jsx)("ambientLight", {
								position: [-0.344, 0, 0],
								intensity: .4
							}), (0, C.jsx)("pointLight", {
								castShadow: !0,
								"shadow-mapSize-width": 2048,
								"shadow-mapSize-height": 2048,
								"shadow-radius": 32,
								position: [-0.047, 3.811, -2.134],
								intensity: .7,
								color: "#FFFFFF"
							}), (0, C.jsx)("pointLight", {
								castShadow: !0,
								"shadow-mapSize-width": 2048,
								"shadow-mapSize-height": 2048,
								"shadow-radius": 32,
								position: [-3.673, 4.471, 3.83],
								intensity: .4,
								color: "#FFFCEB"
							}), (0, C.jsx)("pointLight", {
								castShadow: !0,
								"shadow-mapSize-width": 2048,
								"shadow-mapSize-height": 2048,
								"shadow-radius": 32,
								position: [3.234, 2.358, -5.176],
								intensity: 1.2,
								color: "#99B9FF"
							}), (0, C.jsx)("pointLight", {
								position: [-3.834, 1.637, -2.054],
								intensity: 1,
								color: "#FDD3D5"
							}), (0, C.jsx)("spotLight", {
								castShadow: !0,
								"shadow-mapSize-width": 2048,
								"shadow-mapSize-height": 2048,
								"shadow-radius": 32,
								position: [9.965, .312, 11.389],
								intensity: .7,
								color: "#FFF3E6",
								angle: .314
							}), (0, C.jsx)(E.Suspense, {
								fallback: null,
								children: (0, C.jsx)(aw, {
									width: void 0 === c ? 1 : c,
									height: e,
									downloadRef: f,
									setAvatar: g,
									lightSkin: h,
									params: i
								})
							}), (0, C.jsx)(an.z, {
								enableZoom: !1,
								minAzimuthAngle: -Math.PI / 7.2,
								maxAzimuthAngle: Math.PI / 7.2,
								minPolarAngle: Math.PI / 2,
								maxPolarAngle: Math.PI / 2
							})]
						})
					})
				},
				x = a(9686),
				ay = a.n(x),
				y = a(9237),
				az = a.n(y),
				aA = function() {
					return (0, C.jsxs)("div", {
						className: az().loader,
						children: [(0, C.jsx)("span", {}), (0, C.jsx)("span", {}), (0, C.jsx)("span", {}), (0, C.jsx)("span", {}), (0, C.jsx)("span", {}), (0, C.jsx)("span", {}), (0, C.jsx)("span", {}), (0, C.jsx)("span", {})]
					})
				},
				z = a(7593),
				aB = a.n(z),
				aC = function(a) {
					var c = a.label,
						b = a.value,
						d = a.type,
						e = a.onChange;
					return (0, C.jsxs)("div", {
						className: J()(aB().field, (0, I.Z)({}, aB().focus, b.length > 0)),
						children: [(0, C.jsx)("label", {
							className: aB().label,
							children: c
						}), (0, C.jsx)("input", {
							className: aB().input,
							type: d || "text",
							value: b,
							onChange: e,
							required: !0
						})]
					})
				},
				aD = function(d, e, c) {
					var a = window.grecaptcha,
						b = "6LdYW5UUAAAAAG8PWYEdNFD1Gqt2pRFSFObQB085";
					if (!a || !b) return c({
						error: "Unable to process login"
					});
					a.execute(b, {
						action: "login"
					}).then(function(a) {
						at().post("".concat("https://ui8.net", "/account/signin?json=1"), {
							email: d,
							password: e,
							next: "/",
							rcToken: a
						}).then(function(a) {
							c({
								error: a.data.error,
								status: a.data.status
							})
						}).catch(function() {
							c({
								error: "Unable to process login"
							})
						})
					})
				},
				aE = function(a) {
					var k = a.setSignIn,
						b = a.goToSignUp,
						c = (0, E.useState)(""),
						h = c[0],
						l = c[1],
						d = (0, E.useState)(""),
						i = d[0],
						m = d[1],
						e = (0, E.useState)({}),
						f = e[0],
						n = e[1],
						g = (0, E.useState)(!1),
						j = g[0],
						o = g[1],
						p = function(a) {
							o(!1), n(a), k(!a.error)
						};
					return (0, C.jsxs)(C.Fragment, {
						children: [(0, C.jsxs)("div", {
							className: ay().left,
							children: [(0, C.jsx)("div", {
								className: ay().title,
								children: "Sign in to UI8"
							}), (0, C.jsx)("div", {
								className: ay().preview,
								children: (0, C.jsx)(P(), {
									className: ay().pic,
									src: "./images/sign-in.png",
									width: 200,
									height: 200,
									alt: "Sign In"
								})
							}), (0, C.jsx)("button", {
								className: ay().link,
								onClick: b,
								children: "Don't have an account? Click here to sign up"
							})]
						}), (0, C.jsxs)("div", {
							className: ay().right,
							children: [(0, C.jsx)("div", {
								className: J()(ay().title, ay().titleRight),
								children: "Sign in to UI8"
							}), (0, C.jsxs)("form", {
								className: ay().form,
								onSubmit: function(a) {
									a.preventDefault(), o(!0), aD(h, i, p)
								},
								children: [(0, C.jsx)(aC, {
									label: "Email",
									value: h,
									type: "email",
									onChange: function(a) {
										return l(a.target.value)
									}
								}), (0, C.jsx)(aC, {
									label: "Password",
									value: i,
									type: "password",
									onChange: function(a) {
										return m(a.target.value)
									}
								}), f.error && (0, C.jsx)("div", {
									className: ay().error,
									children: f.error
								}), j ? (0, C.jsx)("div", {
									className: ay().loader,
									children: (0, C.jsx)(aA, {})
								}) : (0, C.jsx)("button", {
									className: ay().btn,
									children: "Log In"
								})]
							}), (0, C.jsx)("button", {
								className: J()(ay().link, ay().linkMobile),
								onClick: b,
								children: "Don't have an account? Click here to sign up"
							})]
						})]
					})
				},
				aF = function(d, e, f, g, h, c) {
					var a = window.grecaptcha,
						b = "6LdYW5UUAAAAAG8PWYEdNFD1Gqt2pRFSFObQB085";
					if (!a || !b) return c({
						error: "Unable to process registration"
					});
					a.execute(b, {
						action: "registration"
					}).then(function(a) {
						at().post("".concat("https://ui8.net", "/account/register?json=1"), {
							first_name: d,
							last_name: e,
							email: f,
							password: g,
							redirectTo: h,
							rcToken: a
						}).then(function(a) {
							c({
								error: a.data.error,
								status: a.data.status
							})
						}).catch(function() {
							c({
								error: "Unable to process registration"
							})
						})
					})
				},
				aG = [{
					src: "./images/sign-up-hint-1.png",
					text: "Follow and connect with a global network of talented designers and content creators"
				}, {
					src: "./images/sign-up-hint-2.png",
					text: "Unlimited access to our growing library of premium-quality freebies"
				}, {
					src: "./images/sign-up-hint-3.png",
					text: "Easily manage purchases, downloads, and favorite products"
				}, ],
				aH = function(j) {
					var a = j.goToSignIn,
						b = (0, E.useState)(""),
						k = b[0],
						q = b[1],
						c = (0, E.useState)(""),
						l = c[0],
						r = c[1],
						d = (0, E.useState)(""),
						m = d[0],
						s = d[1],
						e = (0, E.useState)(""),
						n = e[0],
						t = e[1],
						f = (0, E.useState)({}),
						g = f[0],
						u = f[1],
						h = (0, E.useState)(!1),
						o = h[0],
						v = h[1],
						i = (0, E.useState)(!1),
						p = i[0],
						w = i[1],
						x = function(a) {
							v(!1), u(a), w("success" === a.status)
						};
					return (0, C.jsxs)(C.Fragment, {
						children: [(0, C.jsxs)("div", {
							className: ay().left,
							children: [(0, C.jsx)("div", {
								className: ay().title,
								children: "Create a UI8 Account"
							}), (0, C.jsx)("div", {
								className: ay().hints,
								children: aG.map(function(a, b) {
									return (0, C.jsxs)("div", {
										className: ay().hint,
										children: [(0, C.jsx)("div", {
											className: ay().icon,
											children: (0, C.jsx)(P(), {
												src: a.src,
												width: 52,
												height: 52,
												alt: "Icon"
											})
										}), (0, C.jsx)("div", {
											className: ay().text,
											children: a.text
										})]
									}, b)
								})
							}), (0, C.jsx)("button", {
								className: ay().link,
								onClick: a,
								children: "Already have an account?"
							})]
						}), (0, C.jsx)("div", {
							className: ay().right,
							children: p ? (0, C.jsx)("div", {
								className: ay().msg,
								children: "Please check your inbox and confirm your email address to finish setting up your account."
							}) : (0, C.jsxs)(C.Fragment, {
								children: [(0, C.jsx)("div", {
									className: J()(ay().title, ay().titleRight),
									children: "Create a UI8 Account"
								}), (0, C.jsxs)("form", {
									className: ay().form,
									onSubmit: function(a) {
										a.preventDefault(), v(!0), aF(k, l, m, n, window.location.href, x)
									},
									children: [(0, C.jsxs)("div", {
										className: ay().row,
										children: [(0, C.jsx)("div", {
											className: ay().col,
											children: (0, C.jsx)(aC, {
												label: "First Name",
												value: k,
												onChange: function(a) {
													return q(a.target.value)
												}
											})
										}), (0, C.jsx)("div", {
											className: ay().col,
											children: (0, C.jsx)(aC, {
												label: "Last Name",
												value: l,
												onChange: function(a) {
													return r(a.target.value)
												}
											})
										})]
									}), (0, C.jsx)(aC, {
										label: "Email",
										value: m,
										type: "email",
										onChange: function(a) {
											return s(a.target.value)
										}
									}), (0, C.jsx)(aC, {
										label: "Password",
										value: n,
										type: "password",
										onChange: function(a) {
											return t(a.target.value)
										}
									}), g.error && (0, C.jsx)("div", {
										className: ay().error,
										children: g.error
									}), o ? (0, C.jsx)("div", {
										className: ay().loader,
										children: (0, C.jsx)(aA, {})
									}) : (0, C.jsx)("button", {
										className: ay().btn,
										children: "Sign Up"
									})]
								}), (0, C.jsx)("button", {
									className: J()(ay().link, ay().linkMobile),
									onClick: a,
									children: "Already have an account?"
								})]
							})
						})]
					})
				},
				aI = function(a) {
					var d = a.visible,
						e = a.setSignIn,
						b = a.onClose,
						c = (0, E.useState)("sign-up"),
						f = c[0],
						g = c[1];
					return (0, C.jsxs)(Y, {
						containerClassName: ay().container,
						visible: d,
						onClose: b,
						hideClose: !0,
						children: [(0, C.jsx)("button", {
							className: ay().close,
							onClick: b,
							children: (0, C.jsx)("svg", {
								width: "12",
								height: "12",
								viewBox: "0 0 32 32",
								children: (0, C.jsx)("path", {
									d: "M18.02 16l13.97-13.96L29.98 0 16 13.982 2.02 0 .012 2.04 13.98 16-.004 29.985 2 32l14-13.982L30 32l2.014-2.014L18.02 16z"
								})
							})
						}), "sign-up" === f ? (0, C.jsx)(aH, {
							goToSignIn: function() {
								return g("sign-in")
							}
						}) : (0, C.jsx)(aE, {
							setSignIn: e,
							goToSignUp: function() {
								return g("sign-up")
							}
						})]
					})
				},
				A = a(5944),
				aJ = a.n(A),
				aK = function(a) {
					var b = a.visible,
						c = a.content;
					return (0, C.jsxs)("div", {
						className: J()(aJ().message, (0, I.Z)({}, aJ().visible, b)),
						children: [(0, C.jsx)("svg", {
							width: "16px",
							height: "16px",
							viewBox: "0 0 32 32",
							xmlns: "http://www.w3.org/2000/svg",
							children: (0, C.jsx)("path", {
								d: "M18.0185378,16.0002802 L31.9875103,2.03894584 L29.9813969,0.000345421604 L16,13.9817423 L2.01860308,0.000345421604 L0.012489713,2.03894584 L13.9814622,16.0002802 L-0.00375381455,29.9854962 L2.01040741,31.9996574 L16,18.0177142 L29.9895926,31.9996574 L32.0037538,29.9854962 L18.0185378,16.0002802 Z"
							})
						}), c]
					})
				},
				aL = function(a) {
					a(!1)
					// at().get("".concat("https://ui8.net", "/api/me"), {
					// 	withCredentials: !0
					// }).then(function(b) {
					// 	a(!!b.data.user.email)
					// }).catch(function() {
					// 	a(!1)
					// })
				},
				aM = function(b) {
					var a = b.split("-").map(function(a) {
						return parseInt(a)
					});
					return 8 === a.length && a.every(function(a) {
						return a > 0 && a <= 12
					})
				},
				aN = function(b) {
					var a = b.split("-").map(function(a) {
						return parseInt(a)
					});
					return {
						face: a[0],
						hair: a[1],
						eyebrows: a[2],
						sunglasses: a[3],
						clothes: a[4],
						necklace: a[5],
						earrings: a[6],
						tattoo: a[7]
					}
				},
				aO = {
					face: 1,
					hair: 2,
					eyebrows: 1,
					sunglasses: 1,
					clothes: 1,
					necklace: 1,
					earrings: 1,
					tattoo: 1
				},
				aP = function(n) {
					var y = n.queryParams,
						d = (0, E.useState)(!1),
						a = d[0],
						o = d[1],
						e = (0, E.useState)(null),
						p = e[0],
						q = e[1],
						f = (0, E.useState)("#CCD7D6"),
						b = f[0],
						r = f[1],
						g = (0, E.useState)(!0),
						h = g[0],
						s = g[1],
						i = (0, E.useState)(aO),
						c = i[0],
						t = i[1],
						z = (0, F.useRouter)();
					(0, E.useEffect)(function() {
						y && aM(y) ? t(aN(y)) : z.push({
							query: {}
						})
					}, []);
					var u = (0, G.S)().progress,
						j = (0, E.useRef)(null);
					(0, E.useEffect)(function() {
						100 === u && o(!0)
					}, [u, o]), (0, E.useEffect)(function() {
						document.body.style.backgroundColor = b
					}, [b]);
					var k = (0, E.useState)(!1),
						v = k[0],
						A = k[1],
						l = (0, E.useState)(!1),
						w = l[0],
						B = l[1],
						m = (0, E.useState)(!1),
						x = m[0],
						D = m[1];
					(0, E.useEffect)(function() {
						aL(A)
					}, []);
					var I = function() {
						D(!0), setTimeout(function() {
							return D(!1)
						}, 4e3)
					};
					return (0, C.jsxs)("div", {
						className: H().container,
						children: [(0, C.jsx)(L, {
							loaded: a
						}), (0, C.jsx)(af, {
							loaded: a,
							logged: v,
							openAuth: function() {
								return B(!0)
							},
							params: c,
							downloadRef: j,
							color: b,
							avatar: p
						}), (0, C.jsx)(ax, {
							downloadRef: j,
							setAvatar: q,
							lightSkin: h,
							params: c
						}), a && (0, C.jsx)(al, {
							color: b,
							setColor: r,
							lightSkin: h,
							setLightSkin: s,
							params: c,
							setParams: t
						}), (0, C.jsx)(aI, {
							visible: w,
							setSignIn: function(a) {
								A(a), B(!a), a && I()
							},
							onClose: function() {
								return B(!1)
							}
						}), (0, C.jsx)(aK, {
							visible: x,
							content: "Welcome back!"
						})]
					})
				},
				aQ = !0,
				aR = function(a) {
					var b = a.image,
						c = (0, F.useRouter)().query.p;
					return (0, C.jsxs)(C.Fragment, {
						children: [(0, C.jsxs)(D(), {
							children: [(0, C.jsx)("title", {
								children: "Avatar Builder"
							}), (0, C.jsx)("meta", {
								name: "viewport",
								content: "width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"
							}), (0, C.jsx)("meta", {
								name: "description",
								content: "Peeps Avatar Builder by UI8.net"
							}), (0, C.jsx)("meta", {
								name: "twitter:card",
								content: "summary"
							}), (0, C.jsx)("meta", {
								property: "og:url",
								content: "http://peeps.ui8.net/"
							}), (0, C.jsx)("meta", {
								property: "og:title",
								content: "Peeps Avatar Builder @UI8"
							}), (0, C.jsx)("meta", {
								property: "og:description",
								content: "Look what I just made with the Peeps Avatar Builder @UI8"
							}), (0, C.jsx)("meta", {
								property: "og:image",
								content: b
							})]
						}), (0, C.jsx)(aP, {
							queryParams: c
						})]
					})
				}
		},
		5901: function(a) {
			a.exports = {
				modal: "About_modal__RIPvg",
				about: "About_about__8pB2R",
				content: "About_content__mS55B",
				images: "About_images__LTHcp",
				foot: "About_foot__7Oess",
				terms: "About_terms__VUtUw"
			}
		},
		9686: function(a) {
			a.exports = {
				container: "Auth_container__bPz_p",
				close: "Auth_close__98evr",
				left: "Auth_left__h81_7",
				title: "Auth_title__rKKWX",
				titleRight: "Auth_titleRight__oeuYl",
				preview: "Auth_preview__5K17d",
				pic: "Auth_pic__ksBkk",
				hint: "Auth_hint__KxaJQ",
				icon: "Auth_icon__lfDoG",
				text: "Auth_text__r2xLY",
				link: "Auth_link___22aI",
				linkPassword: "Auth_linkPassword__7JqSA",
				linkMobile: "Auth_linkMobile__knfTF",
				right: "Auth_right__UDJbY",
				row: "Auth_row__3tmkA",
				col: "Auth_col__9o46C",
				loader: "Auth_loader__83YIy",
				btn: "Auth_btn__wTp3y",
				error: "Auth_error__WUqWu",
				msg: "Auth_msg__uHSnR"
			}
		},
		7593: function(a) {
			a.exports = {
				field: "Field_field__rKR0P",
				focus: "Field_focus__rMfTp",
				label: "Field_label__JcDKD",
				input: "Field_input__e4eI2"
			}
		},
		9237: function(a) {
			a.exports = {
				loader: "Loader_loader__wMH0W",
				circleRotate: "Loader_circleRotate__IykZA"
			}
		},
		5944: function(a) {
			a.exports = {
				message: "Message_message__CmFod",
				error: "Message_error__AsmXX",
				visible: "Message_visible__3iRlU"
			}
		},
		8172: function(a) {
			a.exports = {
				container: "Container_container__jvqQM"
			}
		},
		8644: function(a) {
			a.exports = {
				created: "Created_created__AQUpU"
			}
		},
		2332: function(a) {
			a.exports = {
				modal: "Download_modal__UrM__",
				download: "Download_download__tbqvA",
				avatar: "Download_avatar__Kkwxt",
				inner: "Download_inner__oVYxa",
				content: "Download_content__1eHlp",
				buttons: "Download_buttons__Tf1zr",
				button: "Download_button__UZ264",
				created: "Download_created__N_dDo"
			}
		},
		8965: function(a) {
			a.exports = {
				editor: "Editor_editor__4W3Nr",
				actions: "Editor_actions__FuOIS",
				actionsColor: "Editor_actionsColor__u_paD",
				action: "Editor_action__hCEuT",
				active: "Editor_active__sa9UB",
				skin1: "Editor_skin1__EQaJa",
				skin2: "Editor_skin2__aB3HT",
				head: "Editor_head__ybmLi",
				tab: "Editor_tab__tinIT",
				tabRandomize: "Editor_tabRandomize__SX82q",
				previews: "Editor_previews__erqSe",
				preview: "Editor_preview__rflbB"
			}
		},
		7316: function(a) {
			a.exports = {
				picker: "Picker_picker__PmJIf",
				field: "Picker_field__0kX5b",
				label: "Picker_label__ymggG",
				box: "Picker_box__grO_d"
			}
		},
		7342: function(a) {
			a.exports = {
				header: "Header_header__c7sEG",
				logo: "Header_logo__Y_FUf",
				burger: "Header_burger__I19bE",
				download: "Header_download__0YPe_",
				producthunt: "Header_producthunt__01t6U"
			}
		},
		6542: function(a) {
			a.exports = {
				image: "Image_image__B9LmF",
				loaded: "Image_loaded__pM5Gt"
			}
		},
		8647: function(a) {
			a.exports = {
				loader: "Loader_loader__hyo11",
				hidden: "Loader_hidden__jfG9p",
				inner: "Loader_inner__BYbk7",
				skLinRotate: "Loader_skLinRotate__KhnZc"
			}
		},
		8678: function(a) {
			a.exports = {
				modal: "Modal_modal__TObGE",
				close: "Modal_close__9jAu0"
			}
		},
		6910: function(a) {
			a.exports = {
				scene: "Scene_scene__DH6dq"
			}
		}
	},
	function(a) {
		a.O(0, [737, 611, 774, 888, 179], function() {
			var b;
			return a(a.s = 8312)
		}), _N_E = a.O()
	}
])