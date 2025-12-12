package middleware

import (
	"fmt"
	"net/http"
	"runtime/debug"

	"github.com/QuantumNous/new-api/common"
	"github.com/gin-gonic/gin"
)

// 变体思路：
// 1) 基础版：保持匿名函数工厂，直接返回 gin.HandlerFunc。
// 2) 命名函数版：提取独立 handler（如 relayPanicRecover），工厂返回命名函数，便于链式或函数式组合。
// 3) 配置版：工厂接受可选参数（日志输出函数、错误响应构造器），返回定制化 handler。
// 4) 链式适配版：作为中间件适配器，接受/返回下游 handler 或 builder，方便在自定义链路中插入。
// 5) 无状态纯函数版：移除包级依赖，纯输入输出，便于测试与函数式管线组合。
// 6) 钩子注入版：支持注入日志/报警/指标回调或响应格式化器，实现可插拔扩展。
func RelayPanicRecover() gin.HandlerFunc {
	return func(c *gin.Context) {
		defer func() {
			if err := recover(); err != nil {
				common.SysLog(fmt.Sprintf("panic detected: %v", err))
				common.SysLog(fmt.Sprintf("stacktrace from panic: %s", string(debug.Stack())))
				c.JSON(http.StatusInternalServerError, gin.H{
					"error": gin.H{
						"message": fmt.Sprintf("Panic detected, error: %v. Please submit a issue here: https://github.com/Calcium-Ion/new-api", err),
						"type":    "new_api_panic",
					},
				})
				c.Abort()
			}
		}()
		c.Next()
	}
}
